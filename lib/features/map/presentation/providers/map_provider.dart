// RF-0306: estado del mapa con Riverpod
import 'dart:async';

import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscriptions/domain/constants/zonas_administrativas.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/repositories/map_repository.dart';
import 'map_repository_provider.dart';

class MapState {
  final List<AlertEntity> allAlerts;
  final List<AlertEntity> filteredAlerts;
  final Map<String, LatLng> positions;
  final AlertLevel? levelFilter;
  final AlertSource? sourceFilter;
  final bool onlyMonitoredBarrios;
  final String? zonaFilter;
  final String? barrioFilter;
  final int? proximityRadiusMeters;
  final int secondsSinceUpdate;
  final LatLng center;
  final AlertEntity? lastIncomingAlert;
  final bool isLoading;
  final String errorMessage;

  const MapState({
    required this.allAlerts,
    required this.filteredAlerts,
    required this.positions,
    required this.levelFilter,
    required this.sourceFilter,
    required this.onlyMonitoredBarrios,
    required this.zonaFilter,
    required this.barrioFilter,
    required this.proximityRadiusMeters,
    required this.secondsSinceUpdate,
    required this.center,
    required this.lastIncomingAlert,
    this.isLoading = false,
    this.errorMessage = '',
  });

  factory MapState.initial({
    bool onlyMonitoredBarrios = false,
    int? proximityRadiusMeters = 3000,
    String? zonaFilter,
  }) {
    return MapState(
      allAlerts: const [],
      filteredAlerts: const [],
      positions: const {},
      levelFilter: null,
      sourceFilter: null,
      onlyMonitoredBarrios: onlyMonitoredBarrios,
      zonaFilter: zonaFilter,
      barrioFilter: null,
      proximityRadiusMeters: proximityRadiusMeters,
      secondsSinceUpdate: 0,
      center: milagroMapCenter,
      lastIncomingAlert: null,
      isLoading: true,
    );
  }

  MapState copyWith({
    List<AlertEntity>? allAlerts,
    List<AlertEntity>? filteredAlerts,
    Map<String, LatLng>? positions,
    AlertLevel? levelFilter,
    AlertSource? sourceFilter,
    bool? onlyMonitoredBarrios,
    String? zonaFilter,
    bool clearZonaFilter = false,
    String? barrioFilter,
    bool clearBarrioFilter = false,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
    int? secondsSinceUpdate,
    LatLng? center,
    AlertEntity? lastIncomingAlert,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      allAlerts: allAlerts ?? this.allAlerts,
      filteredAlerts: filteredAlerts ?? this.filteredAlerts,
      positions: positions ?? this.positions,
      levelFilter: levelFilter,
      sourceFilter: sourceFilter,
      onlyMonitoredBarrios: onlyMonitoredBarrios ?? this.onlyMonitoredBarrios,
      zonaFilter: clearZonaFilter ? null : (zonaFilter ?? this.zonaFilter),
      barrioFilter: clearBarrioFilter
          ? null
          : (barrioFilter ?? this.barrioFilter),
      proximityRadiusMeters: clearProximityRadius
          ? null
          : (proximityRadiusMeters ?? this.proximityRadiusMeters),
      secondsSinceUpdate: secondsSinceUpdate ?? this.secondsSinceUpdate,
      center: center ?? this.center,
      lastIncomingAlert: lastIncomingAlert,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MapNotifier extends Notifier<MapState> {
  late final MapRepository _repository;
  Timer? _updateTimer;

  @override
  MapState build() {
    _repository = ref.watch(mapRepositoryProvider);
    ref.onDispose(() {
      _updateTimer?.cancel();
    });

    final auth = ref.watch(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);
    final userZona = auth.user?.zona;

    ref.listen(barriosSubscribedProvider, (prev, next) {
      if (next.isEmpty && state.barrioFilter != null) {
        applyFilters(clearBarrioFilter: true);
      }
      _refilter();
    });
    ref.listen(
      authProvider.select((s) => '${s.user?.zona}|${s.user?.barrio}'),
      (prev, next) {
        if (prev != null && prev != next) {
          final newZona = ref.read(authProvider).user?.zona;
          state = state.copyWith(zonaFilter: newZona, clearBarrioFilter: true);
        }
        _refilter();
      },
    );

    Future.microtask(_bootstrap);
    return MapState.initial(
      onlyMonitoredBarrios: isCitizen,
      proximityRadiusMeters: isCitizen ? null : 3000,
      zonaFilter: isCitizen ? userZona : null,
    );
  }

  List<String> _monitoredBarrios() => ref.read(monitoredBarriosProvider);

  LatLng _proximityCenter() => ref.read(userLocationProvider).position;

  String? _effectiveZonaFilter(String? zonaFilter) {
    if (zonaFilter != null) return zonaFilter;
    final auth = ref.read(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);
    if (isCitizen) return auth.user?.zona;
    return null;
  }

  void _refilter() {
    if (state.allAlerts.isEmpty) return;
    state = state.copyWith(
      filteredAlerts: _applyCurrentFilters(state.allAlerts),
    );
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final alerts = (await _repository.getActiveAlerts())
          .where((alert) => alert.estado == 'activa')
          .toList();
      if (!ref.mounted) return;

      final positions = positionsFromAlerts(alerts);
      final auth = ref.read(authProvider);
      final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);
      final proximity = isCitizen ? null : (state.proximityRadiusMeters ?? 3000);
      final userZona = auth.user?.zona;

      state = state.copyWith(
        allAlerts: alerts,
        positions: positions,
        onlyMonitoredBarrios: isCitizen,
        proximityRadiusMeters: proximity,
        zonaFilter: isCitizen ? userZona : state.zonaFilter,
        filteredAlerts: _applyCurrentFilters(alerts),
        secondsSinceUpdate: 0,
        lastIncomingAlert: null,
        isLoading: false,
      );
      _startSubtitleTimer();
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

  static const _distance = Distance();

  List<AlertEntity> _applyCurrentFilters(List<AlertEntity> alerts) {
    final monitored = _monitoredBarrios();
    final auth = ref.read(authProvider);
    final user = auth.user;
    final isCitizen = user != null && !(user.isVisitor);
    final userZona = user?.zona;
    final userBarrio = user?.barrio;
    final effectiveZona = _effectiveZonaFilter(state.zonaFilter);

    return alerts.where((alert) {
      final levelMatches =
          state.levelFilter == null || alert.level == state.levelFilter;
      final sourceMatches = _matchesSourceFilter(
        alert.source,
        state.sourceFilter,
      );
      final zonaMatches = _matchesZonaFilter(
        alert.zonaNombre,
        effectiveZona: effectiveZona,
        isCitizen: isCitizen,
      );
      final barrioMatches = _matchesBarrioFilter(
        alert,
        barrioFilter: state.barrioFilter,
        onlyMonitoredBarrios: state.onlyMonitoredBarrios,
        monitored: monitored,
        userBarrio: userBarrio,
        userZona: userZona,
        isCitizen: isCitizen,
      );
      final proximityMatches = _matchesProximity(
        alert.positionAt(state.positions),
        center: _proximityCenter(),
        radiusMeters: state.proximityRadiusMeters,
      );
      return levelMatches &&
          sourceMatches &&
          zonaMatches &&
          barrioMatches &&
          proximityMatches;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  bool _matchesZonaFilter(
    String alertZona, {
    required String? effectiveZona,
    required bool isCitizen,
  }) {
    if (effectiveZona == null) return true;
    return alertZona == effectiveZona;
  }

  bool _matchesBarrioFilter(
    AlertEntity alert, {
    required String? barrioFilter,
    required bool onlyMonitoredBarrios,
    required List<String> monitored,
    required String? userBarrio,
    required String? userZona,
    required bool isCitizen,
  }) {
    if (barrioFilter != null) {
      if (barrioFilter.isEmpty) return alert.barrio.isEmpty;
      return alert.barrio == barrioFilter;
    }

    if (!onlyMonitoredBarrios) return true;

    final effectiveZona = _effectiveZonaFilter(state.zonaFilter);
    if (effectiveZona != null &&
        userZona != null &&
        effectiveZona != userZona) {
      return true;
    }

    final zonaSinBarrios = userZona != null && !zonaTieneBarrios(userZona);
    if (zonaSinBarrios || userBarrio == null || userBarrio.isEmpty) {
      return true;
    }

    if (monitored.isEmpty) return true;
    return monitored.contains(alert.barrio) || alert.barrio.isEmpty;
  }

  bool _matchesSourceFilter(AlertSource source, AlertSource? filter) {
    if (filter == null) return true;
    if (filter == AlertSource.sensor_audio) {
      return source == AlertSource.sensor_audio ||
          source == AlertSource.sensor_video ||
          source == AlertSource.sensor_hidrico;
    }
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

  bool _isLoggedInCitizen() {
    final auth = ref.read(authProvider);
    return auth.user != null && !(auth.user?.isVisitor ?? true);
  }

  void _startSubtitleTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      state = state.copyWith(secondsSinceUpdate: state.secondsSinceUpdate + 30);
    });
  }

  void applyFilters({
    AlertLevel? level,
    AlertSource? source,
    String? zonaFilter,
    bool clearZonaFilter = false,
    String? barrioFilter,
    bool clearBarrioFilter = false,
    bool? onlyMonitoredBarrios,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
  }) {
    final lvl = level ?? state.levelFilter;
    final src = source ?? state.sourceFilter;
    final isCitizen = _isLoggedInCitizen();
    final onlyMonitored = isCitizen
        ? true
        : (onlyMonitoredBarrios ?? state.onlyMonitoredBarrios);

    String? zona;
    if (clearZonaFilter) {
      zona = isCitizen ? ref.read(authProvider).user?.zona : null;
    } else if (zonaFilter != null) {
      zona = zonaFilter;
    } else {
      zona = state.zonaFilter;
    }

    final barrio = clearBarrioFilter
        ? null
        : (barrioFilter ?? state.barrioFilter);
    final proximity = isCitizen
        ? null
        : (clearProximityRadius
              ? null
              : (proximityRadiusMeters ?? state.proximityRadiusMeters));

    state = state.copyWith(
      levelFilter: lvl,
      sourceFilter: src,
      onlyMonitoredBarrios: onlyMonitored,
      zonaFilter: zona,
      clearZonaFilter: false,
      barrioFilter: barrio,
      clearBarrioFilter: clearBarrioFilter,
      proximityRadiusMeters: proximity,
      clearProximityRadius: clearProximityRadius,
      filteredAlerts: _applyCurrentFilters(state.allAlerts),
    );
  }

  void setBarrioFilter(String? barrio) {
    applyFilters(barrioFilter: barrio, clearBarrioFilter: barrio == null);
  }

  void centerOnAlert(AlertEntity alert) {
    final position = state.positions[alert.id] ?? alert.position;
    if (position != null) {
      state = state.copyWith(center: position);
    }
  }

  void prependAlert(AlertEntity alert, LatLng position) {
    final updated = state.allAlerts.isEmpty
        ? [alert]
        : [alert, ...state.allAlerts];

    final positions = {...state.positions, alert.id: position};

    var filtered = _applyCurrentFilters(updated);

    if (alert.isSos && !filtered.any((a) => a.id == alert.id)) {
      state = state.copyWith(
        levelFilter: null,
        sourceFilter: null,
        barrioFilter: null,
      );
      filtered = _applyCurrentFilters(updated);
    }

    state = state.copyWith(
      allAlerts: updated,
      positions: positions,
      filteredAlerts: filtered,
      lastIncomingAlert: alert.isSos ? null : alert,
      secondsSinceUpdate: 0,
      center: position,
    );
  }

  void focusPendingSos(AlertEntity pending) {
    if (state.allAlerts.isEmpty) return;

    final alert = state.allAlerts.firstWhere(
      (a) => a.id == pending.id,
      orElse: () => pending,
    );

    var filtered = state.filteredAlerts;
    if (!filtered.any((a) => a.id == alert.id)) {
      state = state.copyWith(
        levelFilter: null,
        sourceFilter: null,
        barrioFilter: null,
        filteredAlerts: _applyCurrentFilters(state.allAlerts),
      );
      filtered = state.filteredAlerts;
    }

    final position = state.positions[alert.id] ?? state.positions[pending.id];
    state = state.copyWith(
      center: position ?? state.center,
      lastIncomingAlert: null,
    );
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

final mapEffectiveZonaProvider = Provider<String?>((ref) {
  final state = ref.watch(mapProvider);
  final auth = ref.watch(authProvider);
  if (state.zonaFilter != null) return state.zonaFilter;
  final isVisitor = auth.user?.isVisitor ?? true;
  if (!isVisitor && auth.user != null) return auth.user!.zona;
  return null;
});

final showMapZonaFilterProvider = Provider<bool>((ref) => true);

final showMapBarrioFilterProvider = Provider<bool>((ref) {
  final effectiveZona = ref.watch(mapEffectiveZonaProvider);
  if (effectiveZona == null) return false;
  return zonaTieneBarrios(effectiveZona);
});

final mapZonaFilterChipsProvider =
    Provider<List<({String? value, String label})>>((ref) {
      final auth = ref.watch(authProvider);
      final isVisitor = auth.user?.isVisitor ?? true;
      final userZona = auth.user?.zona;

      if (isVisitor || auth.user == null) {
        return [
          (value: null, label: 'Todas las zonas'),
          ...kZonasAdministrativas.map((z) => (value: z, label: z)),
        ];
      }

      return [
        (value: userZona, label: '$userZona (tú)'),
        ...kZonasAdministrativas
            .where((z) => z != userZona)
            .map((z) => (value: z, label: z)),
      ];
    });

final mapBarrioFilterChipsProvider =
    Provider<List<({String? value, String label})>>((ref) {
      if (!ref.watch(showMapBarrioFilterProvider)) return [];

      final auth = ref.watch(authProvider);
      final home = auth.user?.barrio;
      final isVisitor = auth.user?.isVisitor ?? true;
      final effectiveZona = ref.watch(mapEffectiveZonaProvider) ?? 'Milagro';
      final zonaBarrios = barriosDeZona(effectiveZona);

      if (isVisitor || home == null || home.isEmpty) {
        return [
          (value: null, label: 'Todos'),
          ...zonaBarrios.map((b) => (value: b, label: b)),
        ];
      }

      final subscribed = ref.watch(barriosSubscribedProvider);
      final chips = <({String? value, String label})>[
        (value: null, label: 'Todos mis barrios'),
        (value: home, label: '$home (tú)'),
      ];
      for (final b in subscribed) {
        if (b != home && zonaBarrios.contains(b)) {
          chips.add((value: b, label: b));
        }
      }
      return chips;
    });

final mapActiveFiltersSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(mapProvider);
  final auth = ref.watch(authProvider);
  final isVisitor = auth.user?.isVisitor ?? true;
  final home = auth.user?.barrio;
  final userZona = auth.user?.zona;
  final parts = <String>[];

  if (state.zonaFilter != null && state.zonaFilter != userZona) {
    parts.add('Zona: ${state.zonaFilter}');
  } else if (isVisitor && state.zonaFilter != null) {
    parts.add('Zona: ${state.zonaFilter}');
  }

  if (state.levelFilter != null) {
    parts.add('Nivel: ${_levelLabel(state.levelFilter!)}');
  }
  if (state.sourceFilter != null) {
    parts.add('Fuente: ${_sourceLabel(state.sourceFilter!)}');
  }

  if (state.barrioFilter != null) {
    if (!isVisitor && state.barrioFilter == home) {
      parts.add('Barrio: $home (tú)');
    } else {
      parts.add('Barrio: ${state.barrioFilter}');
    }
  }

  if (isVisitor && state.proximityRadiusMeters != null) {
    parts.add('Cerca de ti: ${state.proximityRadiusMeters! ~/ 1000} km');
  }

  if (parts.isEmpty) return null;
  return parts.join(' · ');
});

String _levelLabel(AlertLevel level) {
  return switch (level) {
    AlertLevel.emergencia => 'Emergencia',
    AlertLevel.alerta => 'Alerta',
    AlertLevel.vigilancia => 'Vigilancia',
  };
}

String _sourceLabel(AlertSource source) {
  return switch (source) {
    AlertSource.sensor_audio || AlertSource.sensor_video => 'Sensor',
    AlertSource.sensor_hidrico => 'Hídrico',
    AlertSource.ciudadano => 'Ciudadano',
  };
}
