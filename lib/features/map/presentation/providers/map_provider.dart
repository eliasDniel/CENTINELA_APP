// RF-0306: estado del mapa con Riverpod
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
  final int secondsSinceUpdate;
  final LatLng center;
  final MapAlertEntity? lastIncomingAlert;

  const MapState({
    required this.allAlerts,
    required this.filteredAlerts,
    required this.levelFilter,
    required this.sourceFilter,
    required this.secondsSinceUpdate,
    required this.center,
    required this.lastIncomingAlert,
  });

  factory MapState.initial() {
    return const MapState(
      allAlerts: [],
      filteredAlerts: [],
      levelFilter: null,
      sourceFilter: null,
      secondsSinceUpdate: 0,
      center: LatLng(-2.1344, -79.5874),
      lastIncomingAlert: null,
    );
  }

  MapState copyWith({
    List<MapAlertEntity>? allAlerts,
    List<MapAlertEntity>? filteredAlerts,
    AlertLevel? levelFilter,
    AlertSource? sourceFilter,
    int? secondsSinceUpdate,
    LatLng? center,
    MapAlertEntity? lastIncomingAlert,
  }) {
    return MapState(
      allAlerts: allAlerts ?? this.allAlerts,
      filteredAlerts: filteredAlerts ?? this.filteredAlerts,
      levelFilter: levelFilter,
      sourceFilter: sourceFilter,
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
    Future.microtask(_bootstrap);
    return MapState.initial();
  }

  Future<void> _bootstrap() async {
    final alerts = await _repository.getActiveAlerts();
    state = state.copyWith(
      allAlerts: alerts,
      filteredAlerts: _applyCurrentFilters(alerts, state.levelFilter, state.sourceFilter),
      secondsSinceUpdate: 0,
      lastIncomingAlert: null,
    );
    _startSubtitleTimer();
    _startSimulation();
  }

  List<MapAlertEntity> _applyCurrentFilters(
    List<MapAlertEntity> alerts,
    AlertLevel? level,
    AlertSource? source,
  ) {
    return alerts.where((alert) {
      final levelMatches = level == null || alert.level == level;
      final sourceMatches = source == null || alert.source == source;
      return levelMatches && sourceMatches;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
      final filtered = _applyCurrentFilters(updatedAlerts, state.levelFilter, state.sourceFilter);
      state = state.copyWith(
        allAlerts: updatedAlerts,
        filteredAlerts: filtered,
        secondsSinceUpdate: 0,
        lastIncomingAlert: incoming,
      );
    });
  }

  void applyFilters(AlertLevel? level, AlertSource? source) {
    state = state.copyWith(
      levelFilter: level,
      sourceFilter: source,
      filteredAlerts: _applyCurrentFilters(state.allAlerts, level, source),
    );
  }

  void centerOnAlert(MapAlertEntity alert) {
    state = state.copyWith(center: alert.position);
  }
}

final mapProvider = NotifierProvider.autoDispose<MapNotifier, MapState>(MapNotifier.new);

final alertCountProvider = Provider<Map<String, int>>((ref) {
  final alerts = ref.watch(mapProvider.select((state) => state.filteredAlerts));
  return {
    'emergencia': alerts.where((a) => a.level == AlertLevel.emergencia).length,
    'alerta': alerts.where((a) => a.level == AlertLevel.alerta).length,
    'vigilancia': alerts.where((a) => a.level == AlertLevel.vigilancia).length,
  };
});
