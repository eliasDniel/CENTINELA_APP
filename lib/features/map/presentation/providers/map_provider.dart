// RF-0306: estado del mapa con Riverpod
import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../../domain/repositories/map_repository.dart';
import 'map_repository_provider.dart';

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
      Future.microtask(_bootstrap);
    });

    Future.microtask(_bootstrap);
    return MapState.initial(
      proximityRadiusMeters: isCitizen ? null : 3000,
    );
  }

  LatLng _proximityCenter() => ref.read(userLocationProvider).position;

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final auth = ref.read(authProvider);
      final user = auth.user;
      final isCitizen = user != null && !user.isVisitor;

      final userZonas = isCitizen
          ? await _repository.getZonasByUser(user.uuid)
          : <UserZonaEntity>[];

      final alerts = (await _repository.getActiveAlerts())
          .where((alert) => alert.estado == 'activa')
          .toList();

      if (!ref.mounted) return;

      final positions = positionsFromAlerts(alerts);
      final userPosition = ref.read(userLocationProvider).position;
      final center = userPosition;

      state = state.copyWith(
        userZonas: userZonas,
        allAlerts: alerts,
        positions: positions,
        proximityRadiusMeters: isCitizen ? null : (state.proximityRadiusMeters ?? 3000),
        filteredAlerts: _applyCurrentFilters(alerts, userZonas: userZonas),
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

  Future<void> refreshAlerts() => _bootstrap();

  Future<AlertEntity> loadAlertDetail(String alertId) {
    return _repository.getAlertById(alertId);
  }

  static const _distance = Distance();

  List<AlertEntity> _applyCurrentFilters(
    List<AlertEntity> alerts, {
    List<UserZonaEntity>? userZonas,
  }) {
    return _filterAlerts(
      alerts,
      userZonas: userZonas,
      levelFilter: state.levelFilter,
      sourceFilter: state.sourceFilter,
      zonaIdFilter: state.zonaIdFilter,
      proximityRadiusMeters: state.proximityRadiusMeters,
    );
  }

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
      final proximityMatches = _matchesProximity(
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
      clearProximityRadius: clearProximityRadius,
      filteredAlerts: _filterAlerts(
        state.allAlerts,
        levelFilter: newLevelFilter,
        sourceFilter: newSourceFilter,
        zonaIdFilter: newZonaIdFilter,
        proximityRadiusMeters: newProximityRadius,
      ),
    );
  }

  void clearFilters() {
    final usesProximity = ref.read(mapUsesProximityRadiusProvider);
    applyFilters(
      clearLevelFilter: true,
      clearSourceFilter: true,
      clearZonaIdFilter: true,
      proximityRadiusMeters: usesProximity ? 3000 : null,
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

final mapProvider = NotifierProvider.autoDispose<MapNotifier, MapState>(
  MapNotifier.new,
);

final mapUsesProximityRadiusProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.user == null || (auth.user?.isVisitor ?? true);
});

const mapProximityRadiusOptions = <int>[1000, 3000, 5000];

final mapZonaFilterChipsProvider =
    Provider<List<({String? value, String label})>>((ref) {
      final state = ref.watch(mapProvider);
      final auth = ref.watch(authProvider);
      final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);

      if (!isCitizen || state.userZonas.isEmpty) {
        return const [(value: null, label: 'Todas las zonas')];
      }

      final chips = <({String? value, String label})>[
        (value: null, label: 'Todas mis zonas'),
      ];

      for (final userZona in state.userZonas) {
        final suffix = userZona.isPrincipal ? ' (principal)' : '';
        chips.add((value: userZona.zonaId, label: '${userZona.zona.nombre}$suffix'));
      }

      return chips;
    });

final mapHasActiveFiltersProvider = Provider<bool>((ref) {
  final state = ref.watch(mapProvider);
  final usesProximity = ref.watch(mapUsesProximityRadiusProvider);

  if (state.levelFilter != null ||
      state.sourceFilter != null ||
      state.zonaIdFilter != null) {
    return true;
  }

  if (usesProximity &&
      state.proximityRadiusMeters != null &&
      state.proximityRadiusMeters != 3000) {
    return true;
  }

  return false;
});

final mapActiveFiltersSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(mapProvider);
  final parts = <String>[];

  if (state.zonaIdFilter != null) {
    final zone = state.userZonas
        .where((item) => item.zonaId == state.zonaIdFilter)
        .firstOrNull;
    if (zone != null) {
      parts.add('Zona: ${zone.zona.nombre}');
    }
  }

  if (state.levelFilter != null) {
    parts.add('Nivel: ${_levelLabel(state.levelFilter!)}');
  }
  if (state.sourceFilter != null) {
    parts.add('Fuente: ${_sourceLabel(state.sourceFilter!)}');
  }

  if (ref.watch(mapUsesProximityRadiusProvider) &&
      state.proximityRadiusMeters != null &&
      state.proximityRadiusMeters != 3000) {
    parts.add('Cerca de ti: ${state.proximityRadiusMeters! ~/ 1000} km');
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
