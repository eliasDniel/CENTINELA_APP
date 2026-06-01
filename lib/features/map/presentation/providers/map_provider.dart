// RF-0306: estado del mapa con Riverpod
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscriptions/domain/constants/milagro_barrios.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_active_alerts_usecase.dart';
import '../../infrastructure/datasources/map_local_datasource.dart';
import '../../infrastructure/repositories/map_repository_impl.dart';

final mapLocalDataSourceProvider = Provider<MapLocalDataSource>((ref) {
  return MapLocalDataSource();
});

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl(ref.watch(mapLocalDataSourceProvider));
});

final getActiveAlertsUseCaseProvider = Provider<GetActiveAlertsUseCase>((ref) {
  return GetActiveAlertsUseCase(ref.watch(mapRepositoryProvider));
});

class MapState {
  final List<MapAlertEntity> allAlerts;
  final List<MapAlertEntity> filteredAlerts;
  final AlertLevel? levelFilter;
  final AlertSource? sourceFilter;
  /// RF-0309: si true y [barrioFilter] es null, solo barrio propio + suscritos.
  final bool onlyMonitoredBarrios;
  /// null = Todos (según [onlyMonitoredBarrios]); no null = un barrio concreto.
  final String? barrioFilter;
  /// RF-0306: metros desde [center]. null = sin límite (ciudadanos por barrio).
  final int? proximityRadiusMeters;
  final int secondsSinceUpdate;
  final LatLng center;
  final MapAlertEntity? lastIncomingAlert;

  const MapState({
    required this.allAlerts,
    required this.filteredAlerts,
    required this.levelFilter,
    required this.sourceFilter,
    required this.onlyMonitoredBarrios,
    required this.barrioFilter,
    required this.proximityRadiusMeters,
    required this.secondsSinceUpdate,
    required this.center,
    required this.lastIncomingAlert,
  });

  factory MapState.initial({
    bool onlyMonitoredBarrios = false,
    int? proximityRadiusMeters = 3000,
  }) {
    return MapState(
      allAlerts: const [],
      filteredAlerts: const [],
      levelFilter: null,
      sourceFilter: null,
      onlyMonitoredBarrios: onlyMonitoredBarrios,
      barrioFilter: null,
      proximityRadiusMeters: proximityRadiusMeters,
      secondsSinceUpdate: 0,
      center: milagroMapCenter,
      lastIncomingAlert: null,
    );
  }

  MapState copyWith({
    List<MapAlertEntity>? allAlerts,
    List<MapAlertEntity>? filteredAlerts,
    AlertLevel? levelFilter,
    AlertSource? sourceFilter,
    bool? onlyMonitoredBarrios,
    String? barrioFilter,
    bool clearBarrioFilter = false,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
    int? secondsSinceUpdate,
    LatLng? center,
    MapAlertEntity? lastIncomingAlert,
  }) {
    return MapState(
      allAlerts: allAlerts ?? this.allAlerts,
      filteredAlerts: filteredAlerts ?? this.filteredAlerts,
      levelFilter: levelFilter,
      sourceFilter: sourceFilter,
      onlyMonitoredBarrios: onlyMonitoredBarrios ?? this.onlyMonitoredBarrios,
      barrioFilter: clearBarrioFilter ? null : (barrioFilter ?? this.barrioFilter),
      proximityRadiusMeters: clearProximityRadius
          ? null
          : (proximityRadiusMeters ?? this.proximityRadiusMeters),
      secondsSinceUpdate: secondsSinceUpdate ?? this.secondsSinceUpdate,
      center: center ?? this.center,
      lastIncomingAlert: lastIncomingAlert,
    );
  }
}

class MapNotifier extends Notifier<MapState> {
  late final MapRepository _repository;
  Timer? _updateTimer;
  Timer? _simulationTimer;

  @override
  MapState build() {
    _repository = ref.watch(mapRepositoryProvider);
    ref.onDispose(() {
      _updateTimer?.cancel();
      _simulationTimer?.cancel();
    });

    final auth = ref.watch(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);

    ref.listen(barriosSubscribedProvider, (prev, next) {
      if (next.isEmpty && state.barrioFilter != null) {
        applyFilters(clearBarrioFilter: true);
      }
      _refilter();
    });
    ref.listen(
      authProvider.select((s) => s.user?.barrio),
      (_, __) => _refilter(),
    );

    Future.microtask(_bootstrap);
    return MapState.initial(
      onlyMonitoredBarrios: isCitizen,
      proximityRadiusMeters: isCitizen ? null : 3000,
    );
  }

  List<String> _monitoredBarrios() => ref.read(monitoredBarriosProvider);

  LatLng _proximityCenter() => ref.read(userLocationProvider).position;

  void _refilter() {
    if (state.allAlerts.isEmpty) return;
    state = state.copyWith(
      filteredAlerts: _applyCurrentFilters(
        state.allAlerts,
        level: state.levelFilter,
        source: state.sourceFilter,
        onlyMonitoredBarrios: state.onlyMonitoredBarrios,
        barrioFilter: state.barrioFilter,
        proximityRadiusMeters: state.proximityRadiusMeters,
        center: _proximityCenter(),
      ),
    );
  }

  Future<void> _bootstrap() async {
    final alerts = await _repository.getActiveAlerts();
    
    // Verificar si el provider aún está montado después de la operación asincrónica
    if (!ref.mounted) return;
    
    final auth = ref.read(authProvider);
    final isCitizen = auth.user != null && !(auth.user?.isVisitor ?? true);
    final proximity = isCitizen ? null : (state.proximityRadiusMeters ?? 3000);

    state = state.copyWith(
      allAlerts: alerts,
      onlyMonitoredBarrios: isCitizen,
      proximityRadiusMeters: proximity,
      filteredAlerts: _applyCurrentFilters(
        alerts,
        level: state.levelFilter,
        source: state.sourceFilter,
        onlyMonitoredBarrios: isCitizen,
        barrioFilter: state.barrioFilter,
        proximityRadiusMeters: proximity,
        center: _proximityCenter(),
      ),
      secondsSinceUpdate: 0,
      lastIncomingAlert: null,
    );
    _startSubtitleTimer();
    _startSimulation();
  }

  static const _distance = Distance();

  List<MapAlertEntity> _applyCurrentFilters(
    List<MapAlertEntity> alerts, {
    required AlertLevel? level,
    required AlertSource? source,
    required bool onlyMonitoredBarrios,
    required String? barrioFilter,
    required int? proximityRadiusMeters,
    required LatLng center,
  }) {
    final monitored = _monitoredBarrios();
    return alerts.where((alert) {
      final levelMatches = level == null || alert.level == level;
      final sourceMatches = source == null || alert.source == source;
      final barrioMatches = _matchesBarrioFilter(
        alert.barrio,
        barrioFilter: barrioFilter,
        onlyMonitoredBarrios: onlyMonitoredBarrios,
        monitored: monitored,
      );
      final proximityMatches = _matchesProximity(
        alert.position,
        center: center,
        radiusMeters: proximityRadiusMeters,
      );
      return levelMatches && sourceMatches && barrioMatches && proximityMatches;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  bool _matchesBarrioFilter(
    String barrio, {
    required String? barrioFilter,
    required bool onlyMonitoredBarrios,
    required List<String> monitored,
  }) {
    if (barrioFilter != null) return barrio == barrioFilter;
    if (onlyMonitoredBarrios) {
      return monitored.isEmpty || monitored.contains(barrio);
    }
    return true;
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

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      final incoming = _repository.generateIncomingAlert();
      final updatedAlerts = [incoming, ...state.allAlerts];
      final filtered = _applyCurrentFilters(
        updatedAlerts,
        level: state.levelFilter,
        source: state.sourceFilter,
        onlyMonitoredBarrios: state.onlyMonitoredBarrios,
        barrioFilter: state.barrioFilter,
        proximityRadiusMeters: state.proximityRadiusMeters,
        center: _proximityCenter(),
      );
      state = state.copyWith(
        allAlerts: updatedAlerts,
        filteredAlerts: filtered,
        secondsSinceUpdate: 0,
        lastIncomingAlert: incoming,
      );
    });
  }

  void applyFilters({
    AlertLevel? level,
    AlertSource? source,
    String? barrioFilter,
    bool clearBarrioFilter = false,
    bool? onlyMonitoredBarrios,
    int? proximityRadiusMeters,
    bool clearProximityRadius = false,
  }) {
    final lvl = level ?? state.levelFilter;
    final src = source ?? state.sourceFilter;
    final isCitizen = _isLoggedInCitizen();
    final onlyMonitored =
        isCitizen ? true : (onlyMonitoredBarrios ?? state.onlyMonitoredBarrios);
    final barrio = clearBarrioFilter ? null : (barrioFilter ?? state.barrioFilter);
    final proximity = isCitizen
        ? null
        : (clearProximityRadius
            ? null
            : (proximityRadiusMeters ?? state.proximityRadiusMeters));

    state = state.copyWith(
      levelFilter: lvl,
      sourceFilter: src,
      onlyMonitoredBarrios: onlyMonitored,
      barrioFilter: barrio,
      clearBarrioFilter: clearBarrioFilter,
      proximityRadiusMeters: proximity,
      clearProximityRadius: clearProximityRadius,
      filteredAlerts: _applyCurrentFilters(
        state.allAlerts,
        level: lvl,
        source: src,
        onlyMonitoredBarrios: onlyMonitored,
        barrioFilter: barrio,
        proximityRadiusMeters: proximity,
        center: _proximityCenter(),
      ),
    );
  }

  void setOnlyMonitoredBarrios(bool value) {
    applyFilters(onlyMonitoredBarrios: value, clearBarrioFilter: true);
  }

  void setBarrioFilter(String? barrio) {
    applyFilters(
      barrioFilter: barrio,
      clearBarrioFilter: barrio == null,
    );
  }

  void centerOnAlert(MapAlertEntity alert) {
    state = state.copyWith(center: alert.position);
  }

  /// Inserta alerta SOS (u otra) si el mapa ya está abierto.
  void prependAlert(MapAlertEntity alert) {
    final updated = state.allAlerts.isEmpty
        ? [alert]
        : [alert, ...state.allAlerts];

    var filtered = _applyCurrentFilters(
      updated,
      level: state.levelFilter,
      source: state.sourceFilter,
      onlyMonitoredBarrios: state.onlyMonitoredBarrios,
      barrioFilter: state.barrioFilter,
      proximityRadiusMeters: state.proximityRadiusMeters,
      center: _proximityCenter(),
    );

    // La alerta propia SOS debe verse siempre.
    if (alert.type == AlertType.sos &&
        !filtered.any((a) => a.id == alert.id)) {
      filtered = _applyCurrentFilters(
        updated,
        level: null,
        source: null,
        onlyMonitoredBarrios: state.onlyMonitoredBarrios,
        barrioFilter: null,
        proximityRadiusMeters: state.proximityRadiusMeters,
        center: _proximityCenter(),
      );
      state = state.copyWith(
        levelFilter: null,
        sourceFilter: null,
        barrioFilter: null,
      );
    }

    state = state.copyWith(
      allAlerts: updated,
      filteredAlerts: filtered,
      // No disparar snackbar de "nueva alerta" para SOS propio.
      lastIncomingAlert: alert.type == AlertType.sos ? null : alert,
      secondsSinceUpdate: 0,
      center: alert.position,
    );
  }

  /// Centra el mapa en la alerta SOS recién enviada (p. ej. desde Inicio).
  void focusPendingSos(MapAlertEntity pending) {
    if (state.allAlerts.isEmpty) return;

    final alert = state.allAlerts.firstWhere(
      (a) => a.id == pending.id,
      orElse: () => pending,
    );

    var filtered = state.filteredAlerts;
    if (!filtered.any((a) => a.id == alert.id)) {
      filtered = _applyCurrentFilters(
        state.allAlerts,
        level: null,
        source: null,
        onlyMonitoredBarrios: state.onlyMonitoredBarrios,
        barrioFilter: null,
        proximityRadiusMeters: state.proximityRadiusMeters,
        center: _proximityCenter(),
      );
      state = state.copyWith(
        levelFilter: null,
        sourceFilter: null,
        barrioFilter: null,
        filteredAlerts: filtered,
      );
    }

    state = state.copyWith(
      center: alert.position,
      lastIncomingAlert: null,
    );
  }
}

final mapProvider = NotifierProvider.autoDispose<MapNotifier, MapState>(MapNotifier.new);

/// RF-0306: visitante filtra por distancia; ciudadano por barrio sin límite km.
final mapUsesProximityRadiusProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.user == null || (auth.user?.isVisitor ?? true);
});

const mapProximityRadiusOptions = <int>[1000, 3000, 5000];

/// Solo si hay barrios adicionales suscritos (o es visitante en modo exploración).
final showMapBarrioFilterProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.user?.isVisitor ?? true) return true;
  if (auth.user == null) return false;
  return ref.watch(barriosSubscribedProvider).isNotEmpty;
});

/// Todos + barrios monitoreados (propio + suscritos). Vacío si no aplica filtro.
final mapBarrioFilterChipsProvider =
    Provider<List<({String? value, String label})>>((ref) {
  if (!ref.watch(showMapBarrioFilterProvider)) return [];

  final auth = ref.watch(authProvider);
  final home = auth.user?.barrio;
  final isVisitor = auth.user?.isVisitor ?? true;

  if (isVisitor || home == null) {
    return [
      (value: null, label: 'Todos'),
      ...kMilagroBarrios.map((b) => (value: b, label: b)),
    ];
  }

  final subscribed = ref.watch(barriosSubscribedProvider);
  final chips = <({String? value, String label})>[
    (value: null, label: 'Todos mis barrios'),
    (value: home, label: '$home (tú)'),
  ];
  for (final b in subscribed) {
    if (b != home) chips.add((value: b, label: b));
  }
  return chips;
});

final mapActiveFiltersSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(mapProvider);
  final auth = ref.watch(authProvider);
  final isVisitor = auth.user?.isVisitor ?? true;
  final home = auth.user?.barrio;
  final parts = <String>[];

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
    AlertSource.sensor_audio || AlertSource.sensor_video => 'IoT',
    AlertSource.sensor_hidrico => 'Hídrico',
    AlertSource.ciudadano => 'Ciudadano',
  };
}
