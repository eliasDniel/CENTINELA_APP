// RF-0306: estado del mapa con Riverpod
import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/services/key_value_storage_impl.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/constants/map_alert_window.dart';
import '../../domain/constants/visitor_map_prefs.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/utils/wkt_polygon_parser.dart';
import 'last_sos_alert_provider.dart';
import 'map_repository_provider.dart';
import 'pending_sos_report_provider.dart';

class MapState {
  final List<AlertEntity> allAlerts;
  final List<AlertEntity> filteredAlerts;
  final List<UserZonaEntity> userZonas;
  final Map<String, LatLng> positions;
  final AlertLevel? levelFilter;
  final AlertSource? sourceFilter;
  final String? zonaIdFilter;
  final int? proximityRadiusMeters;
  final LatLng center;
  final bool isLoading;
  final String errorMessage;

  const MapState({
    required this.allAlerts,
    required this.filteredAlerts,
    required this.userZonas,
    required this.positions,
    required this.levelFilter,
    required this.sourceFilter,
    required this.zonaIdFilter,
    required this.proximityRadiusMeters,
    required this.center,
    this.isLoading = false,
    this.errorMessage = '',
  });

  factory MapState.initial({int? proximityRadiusMeters = 3000}) {
    return MapState(
      allAlerts: const [],
      filteredAlerts: const [],
      userZonas: const [],
      positions: const {},
      levelFilter: null,
      sourceFilter: null,
      zonaIdFilter: null,
      proximityRadiusMeters: proximityRadiusMeters,
      center: milagroMapCenter,
      isLoading: true,
    );
  }

  MapState copyWith({
    List<AlertEntity>? allAlerts,
    List<AlertEntity>? filteredAlerts,
    List<UserZonaEntity>? userZonas,
    Map<String, LatLng>? positions,
    AlertLevel? levelFilter,
    bool clearLevelFilter = false,
    AlertSource? sourceFilter,
    bool clearSourceFilter = false,
    String? zonaIdFilter,
    bool clearZonaIdFilter = false,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
    LatLng? center,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      allAlerts: allAlerts ?? this.allAlerts,
      filteredAlerts: filteredAlerts ?? this.filteredAlerts,
      userZonas: userZonas ?? this.userZonas,
      positions: positions ?? this.positions,
      levelFilter: clearLevelFilter ? null : (levelFilter ?? this.levelFilter),
      sourceFilter: clearSourceFilter ? null : (sourceFilter ?? this.sourceFilter),
      zonaIdFilter: clearZonaIdFilter
          ? null
          : (zonaIdFilter ?? this.zonaIdFilter),
      proximityRadiusMeters: clearProximityRadius
          ? null
          : (proximityRadiusMeters ?? this.proximityRadiusMeters),
      center: center ?? this.center,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MapNotifier extends Notifier<MapState> {
  MapRepository get _repository => ref.read(mapRepositoryProvider);

  bool _isCitizen(AuthState auth) =>
      auth.user != null && !(auth.user?.isVisitor ?? true);

  @override
  MapState build() {
    final auth = ref.read(authProvider);
    final isCitizen = _isCitizen(auth);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous == null) return;
      final sameUser = previous.user?.uuid == next.user?.uuid;
      final sameRole = _isCitizen(previous) == _isCitizen(next);
      if (sameUser && sameRole) return;

      if (_isCitizen(next) && !_isCitizen(previous)) {
        state = state.copyWith(clearProximityRadius: true);
      }

      Future.microtask(_bootstrap);
    });

    Future.microtask(_bootstrap);
    return MapState.initial(
      proximityRadiusMeters:
          isCitizen ? null : defaultVisitorProximityRadiusMeters,
    );
  }

  Future<int> _loadVisitorProximityRadius() async {
    final storage = KeyValueStorageImpl();
    final stored = await storage.getValue<int>(visitorProximityRadiusKey);
    if (stored != null && mapProximityRadiusOptions.contains(stored)) {
      return stored;
    }
    return defaultVisitorProximityRadiusMeters;
  }

  Future<void> _persistVisitorProximityRadius(int meters) async {
    if (!mapProximityRadiusOptions.contains(meters)) return;
    await KeyValueStorageImpl().setKeyValue(visitorProximityRadiusKey, meters);
  }

  LatLng _proximityCenter() => ref.read(userLocationProvider).position;

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final auth = ref.read(authProvider);
      final user = auth.user;
      final isCitizen = user != null && !user.isVisitor;
      final isVisitor = user?.isVisitor ?? false;

      final userZonas = isCitizen
          ? await _repository.getZonasByUser(user.uuid)
          : <UserZonaEntity>[];

      final visitorRadius = isVisitor ? await _loadVisitorProximityRadius() : null;

      // Carga inicial: activas + últimas 24 h. Nuevas llegan por WebSocket.
      final alerts = isCitizen
          ? await _repository.getMapAlerts(horas: kMapAlertWindowHours)
          : isVisitor
              ? await _repository.getPublicMapAlerts(horas: kMapAlertWindowHours)
              : (await _repository.getActiveAlerts())
                  .where(
                    (alert) => matchesCitizenMapWindow(
                      createdAt: alert.timestampDate,
                    ),
                  )
                  .toList();

      if (!ref.mounted) return;

      final positions = positionsFromAlerts(alerts);
      final userPosition = ref.read(userLocationProvider).position;
      final center = userPosition;
      final effectiveProximity =
          isCitizen ? null : (visitorRadius ?? state.proximityRadiusMeters);

      state = state.copyWith(
        userZonas: userZonas,
        allAlerts: alerts,
        positions: positions,
        proximityRadiusMeters: effectiveProximity,
        clearProximityRadius: isCitizen,
        filteredAlerts: _filterAlerts(
          alerts,
          userZonas: userZonas,
          levelFilter: state.levelFilter,
          sourceFilter: state.sourceFilter,
          zonaIdFilter: state.zonaIdFilter,
          proximityRadiusMeters: effectiveProximity,
        ),
        center: center,
        isLoading: false,
      );
    } on CustomError catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar las alertas del mapa',
      );
    }
  }

  Future<void> refreshAlerts() => refreshMapContext();

  /// Recarga zonas y alertas (ciudadano) o mapa público (visitante).
  Future<void> refreshMapContext() async {
    await _bootstrap();
  }

  Future<void> onRealtimeAlertEvent(String alertId) async {
    final auth = ref.read(authProvider);
    if (!_isCitizen(auth)) return;

    try {
      final alert = await _repository.getAlertById(alertId);
      if (!ref.mounted) return;

      final alreadyOnMap = state.allAlerts.any((item) => item.id == alert.id);
      if (!alreadyOnMap &&
          !isEligibleForCitizenMap(
            estado: alert.estado,
            createdAt: alert.timestampDate,
          )) {
        return;
      }

      _upsertAlert(alert);
    } catch (_) {
      // La alerta puede no estar disponible aún o fuera de permisos.
    }
  }

  void _upsertAlert(AlertEntity alert) {
    final alerts = [...state.allAlerts];
    final index = alerts.indexWhere((item) => item.id == alert.id);
    if (index >= 0) {
      alerts[index] = alert;
    } else {
      alerts.add(alert);
    }

    final positions = Map<String, LatLng>.from(state.positions);
    final position = alert.position;
    if (position != null) {
      positions[alert.id] = position;
    }

    state = state.copyWith(
      allAlerts: alerts,
      positions: positions,
      filteredAlerts: _filterAlerts(
        alerts,
        levelFilter: state.levelFilter,
        sourceFilter: state.sourceFilter,
        zonaIdFilter: state.zonaIdFilter,
        proximityRadiusMeters: state.proximityRadiusMeters,
      ),
    );

    final pendingReportId = ref.read(pendingSosReportIdProvider);
    if (pendingReportId != null && alert.reporteId == pendingReportId) {
      ref.read(lastSosAlertProvider.notifier).state = alert;
      ref.read(pendingSosReportIdProvider.notifier).state = null;
    }
  }

  Future<AlertEntity> loadAlertDetail(String alertId) {
    final auth = ref.read(authProvider);
    if (auth.user?.isVisitor ?? false) {
      final cached = state.allAlerts
          .where((alert) => alert.id == alertId)
          .firstOrNull;
      if (cached != null) return Future.value(cached);
    }
    return _repository.getAlertById(alertId);
  }

  static const _distance = Distance();

  List<AlertEntity> _filterAlerts(
    List<AlertEntity> alerts, {
    List<UserZonaEntity>? userZonas,
    AlertLevel? levelFilter,
    AlertSource? sourceFilter,
    String? zonaIdFilter,
    int? proximityRadiusMeters,
  }) {
    final zones = userZonas ?? state.userZonas;
    final auth = ref.read(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);

    return alerts.where((alert) {
      final levelMatches = levelFilter == null || alert.level == levelFilter;
      final sourceMatches = _matchesSourceFilter(alert.source, sourceFilter);
      final zonaMatches = _matchesZonaFilter(
        alert,
        zonaIdFilter: zonaIdFilter,
        userZonas: zones,
        isCitizen: isCitizen,
      );
      final proximityMatches = isCitizen ||
          _matchesProximity(
            alert.positionAt(state.positions),
            center: _proximityCenter(),
            radiusMeters: proximityRadiusMeters,
          );
      return levelMatches && sourceMatches && zonaMatches && proximityMatches;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  bool _matchesZonaFilter(
    AlertEntity alert, {
    required String? zonaIdFilter,
    required List<UserZonaEntity> userZonas,
    required bool isCitizen,
  }) {
    if (!isCitizen || userZonas.isEmpty) return true;

    if (zonaIdFilter != null) {
      final selected = userZonas
          .where((zone) => zone.zonaId == zonaIdFilter)
          .firstOrNull;
      if (selected == null) return false;
      final alertZonaId = alert.zonaId ?? alert.zona?.id;
      if (alertZonaId != null && alertZonaId.isNotEmpty) {
        return alertZonaId == selected.zonaId;
      }
      return alert.zonaNombre == selected.zona.nombre;
    }

    return alert.belongsToUserZone(userZonas);
  }

  bool _matchesSourceFilter(AlertSource source, AlertSource? filter) {
    if (filter == null) return true;
    return source == filter;
  }

  bool _matchesProximity(
    LatLng point, {
    required LatLng center,
    required int? radiusMeters,
  }) {
    if (radiusMeters == null) return true;
    final meters = _distance.as(LengthUnit.Meter, center, point);
    return meters <= radiusMeters;
  }

  void applyFilters({
    AlertLevel? level,
    bool clearLevelFilter = false,
    AlertSource? source,
    bool clearSourceFilter = false,
    String? zonaIdFilter,
    bool clearZonaIdFilter = false,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
  }) {
    final auth = ref.read(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);

    final newLevelFilter = clearLevelFilter ? null : level;
    final newSourceFilter = clearSourceFilter ? null : source;
    final newZonaIdFilter = clearZonaIdFilter ? null : zonaIdFilter;
    final newProximityRadius = isCitizen
        ? null
        : (clearProximityRadius
              ? null
              : (proximityRadiusMeters ?? state.proximityRadiusMeters));

    state = state.copyWith(
      levelFilter: newLevelFilter,
      clearLevelFilter: clearLevelFilter,
      sourceFilter: newSourceFilter,
      clearSourceFilter: clearSourceFilter,
      zonaIdFilter: newZonaIdFilter,
      clearZonaIdFilter: clearZonaIdFilter,
      proximityRadiusMeters: newProximityRadius,
      clearProximityRadius: isCitizen || clearProximityRadius,
      filteredAlerts: _filterAlerts(
        state.allAlerts,
        levelFilter: newLevelFilter,
        sourceFilter: newSourceFilter,
        zonaIdFilter: newZonaIdFilter,
        proximityRadiusMeters: newProximityRadius,
      ),
    );

    if (!isCitizen && newProximityRadius != null) {
      _persistVisitorProximityRadius(newProximityRadius);
    }
  }

  void clearFilters() {
    final usesProximity = ref.read(mapUsesProximityRadiusProvider);
    applyFilters(
      clearLevelFilter: true,
      clearSourceFilter: true,
      clearZonaIdFilter: true,
      proximityRadiusMeters: usesProximity ? defaultVisitorProximityRadiusMeters : null,
      clearProximityRadius: !usesProximity,
    );
  }

  void centerOnAlert(AlertEntity alert) {
    final position = state.positions[alert.id] ?? alert.position;
    if (position != null) {
      state = state.copyWith(center: position);
    }
  }

  void focusPendingSos(AlertEntity pending) {
    if (state.allAlerts.isEmpty) return;

    final alert = state.allAlerts.firstWhere(
      (a) => a.id == pending.id,
      orElse: () => pending,
    );

    if (!state.filteredAlerts.any((a) => a.id == alert.id)) {
      state = state.copyWith(
        clearLevelFilter: true,
        clearSourceFilter: true,
        clearZonaIdFilter: true,
        filteredAlerts: _filterAlerts(
          state.allAlerts,
          levelFilter: null,
          sourceFilter: null,
          zonaIdFilter: null,
          proximityRadiusMeters: state.proximityRadiusMeters,
        ),
      );
    }

    final position = state.positions[alert.id] ?? state.positions[pending.id];
    state = state.copyWith(center: position ?? state.center);
  }
}

final mapProvider = NotifierProvider<MapNotifier, MapState>(
  MapNotifier.new,
);

typedef MapAlertCounts = ({int total, int active, int resolved});

final mapAlertCountsProvider = Provider<MapAlertCounts>((ref) {
  final alerts = ref.watch(mapProvider.select((s) => s.filteredAlerts));
  var active = 0;
  var resolved = 0;
  for (final alert in alerts) {
    if (alert.isActiveAlert) {
      active++;
    } else if (alert.isResolvedOnMap) {
      resolved++;
    }
  }
  return (total: alerts.length, active: active, resolved: resolved);
});

final mapShowProximityCircleProvider = Provider<bool>((ref) {
  final usesProximity = ref.watch(mapUsesProximityRadiusProvider);
  if (!usesProximity) return false;
  return ref.watch(mapProvider.select((s) => s.proximityRadiusMeters)) != null;
});

final mapZonePolygonsProvider = Provider<List<Polygon>>((ref) {
  final userZonas = ref.watch(mapProvider.select((s) => s.userZonas));
  final zonaIdFilter = ref.watch(mapProvider.select((s) => s.zonaIdFilter));
  if (userZonas.isEmpty) return const [];

  final polygons = <Polygon>[];
  for (final userZona in userZonas) {
    final points = parseWktPolygon(userZona.zona.geomWkt);
    if (points.isEmpty) continue;
    final isSelected =
        zonaIdFilter == null || zonaIdFilter == userZona.zonaId;
    final baseColor = userZona.isPrincipal
        ? const Color(0xFF42A5F5)
        : const Color(0xFF66BB6A);
    polygons.add(
      Polygon(
        points: points,
        color: baseColor.withValues(alpha: isSelected ? 0.18 : 0.08),
        borderColor: baseColor.withValues(alpha: isSelected ? 0.9 : 0.35),
        borderStrokeWidth: isSelected ? 2.5 : 1.2,
      ),
    );
  }
  return polygons;
});

final mapUsesProximityRadiusProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.user?.isVisitor ?? false;
});

final mapZonaFilterChipsProvider =
    Provider<List<({String? value, String label})>>((ref) {
      final userZonas = ref.watch(mapProvider.select((s) => s.userZonas));
      final auth = ref.watch(authProvider);
      final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);
      if (!isCitizen || userZonas.isEmpty) {
        return const [(value: null, label: 'Todas las zonas')];
      }

      final chips = <({String? value, String label})>[
        (value: null, label: 'Todas mis zonas'),
      ];

      for (final userZona in userZonas) {
        final suffix = userZona.isPrincipal ? ' (principal)' : '';
        chips.add((value: userZona.zonaId, label: '${userZona.zona.nombre}$suffix'));
      }

      return chips;
    });

final mapHasActiveFiltersProvider = Provider<bool>((ref) {
  final filters = ref.watch(
    mapProvider.select(
      (s) => (s.levelFilter, s.sourceFilter, s.zonaIdFilter, s.proximityRadiusMeters),
    ),
  );
  final usesProximity = ref.watch(mapUsesProximityRadiusProvider);

  if (filters.$1 != null ||
      filters.$2 != null ||
      filters.$3 != null) {
    return true;
  }

  if (usesProximity &&
      filters.$4 != null &&
      filters.$4 != defaultVisitorProximityRadiusMeters) {
    return true;
  }

  return false;
});

final mapActiveFiltersSummaryProvider = Provider<String?>((ref) {
  final levelFilter = ref.watch(mapProvider.select((s) => s.levelFilter));
  final sourceFilter = ref.watch(mapProvider.select((s) => s.sourceFilter));
  final zonaIdFilter = ref.watch(mapProvider.select((s) => s.zonaIdFilter));
  final proximityRadius = ref.watch(
    mapProvider.select((s) => s.proximityRadiusMeters),
  );
  final userZonas = ref.watch(mapProvider.select((s) => s.userZonas));
  final parts = <String>[];

  if (zonaIdFilter != null) {
    final zone = userZonas
        .where((item) => item.zonaId == zonaIdFilter)
        .firstOrNull;
    if (zone != null) {
      parts.add('Zona: ${zone.zona.nombre}');
    }
  }

  if (levelFilter != null) {
    parts.add('Nivel: ${_levelLabel(levelFilter)}');
  }
  if (sourceFilter != null) {
    parts.add('Fuente: ${_sourceLabel(sourceFilter)}');
  }

  if (ref.watch(mapUsesProximityRadiusProvider) &&
      proximityRadius != null &&
      proximityRadius != defaultVisitorProximityRadiusMeters) {
    parts.add('Cerca de ti: ${proximityRadius ~/ 1000} km');
  }

  if (parts.isEmpty) return null;
  return parts.join(' · ');
});

String _levelLabel(AlertLevel level) {
  return switch (level) {
    AlertLevel.critico => 'Crítico',
    AlertLevel.urgente => 'Urgente',
    AlertLevel.preventivo => 'Preventivo',
  };
}

String _sourceLabel(AlertSource source) {
  return switch (source) {
    AlertSource.sensor_audio => 'Sensores',
    AlertSource.ciudadano => 'Ciudadanos',
  };
}
