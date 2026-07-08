// RF-0306: página del mapa accesible sin autenticación
import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/map/map_tile_cache.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscriptions/domain/barrio_membership.dart';
import '../widgets/map_floating_controls.dart';
import '../widgets/map_active_filters_banner.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/constants/visitor_map_prefs.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../providers/last_sos_alert_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/alert_detail_sheet.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/map_layers.dart';
import '../../../../core/location/user_heading_provider.dart';
import '../../../../core/location/user_location_provider.dart';
import '../widgets/radius_badge_widget.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();
  late final TileProvider _tileProvider = createCachedMapTileProvider();
  bool _showRadiusHint = false;
  bool _mapReady = false;
  bool _shouldCenterOnUser = true;
  LatLng? _pendingCenter;
  double? _pendingZoom;

  static const _defaultMapZoom = 14.2;

  @override
  void dispose() {
    _mapReady = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showRadiusHintBriefly();
      _showCompassHintOnce();
      _focusPendingSosIfAny();
    });
  }

  bool _isMapTabActive() {
    final page = GoRouterState.of(context).pathParameters['page'];
    return page == '1';
  }

  void _focusPendingSosIfAny() {
    if (!_isMapTabActive()) return;

    final pending = ref.read(lastSosAlertProvider);
    if (pending == null) return;
    final mapState = ref.read(mapProvider);
    if (mapState.allAlerts.isEmpty) return;

    ref.read(mapProvider.notifier).focusPendingSos(pending);
    ref.read(lastSosAlertProvider.notifier).state = null;

    final alert = mapState.allAlerts.firstWhere(
      (a) => a.id == pending.id,
      orElse: () => pending,
    );
    final category = _zonaCategory(alert, mapState.userZonas);
    _openAlertSheet(alert, category);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMapTabActive()) {
      _shouldCenterOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tryCenterOnUserOnce();
      });
    }
    if (_isMapTabActive() && ref.read(lastSosAlertProvider) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusPendingSosIfAny();
      });
    }
  }

  void _showCompassHintOnce() {
    final container = ProviderScope.containerOf(context);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final heading = container.read(userHeadingProvider);
      if (!heading.isAvailable) return;
      AppAlert.info(
        context,
        'Gira el teléfono: el haz azul muestra hacia dónde miras. '
        'Toca la brújula para activar o desactivar.',
        duration: const Duration(seconds: 3),
      );
    });
  }

  void _onMapReady() {
    if (!mounted) return;
    _mapReady = true;
    if (_pendingCenter != null) {
      _safeMoveMap(_pendingCenter!, _pendingZoom ?? _defaultMapZoom);
    } else {
      _tryCenterOnUserOnce();
    }
  }

  void _tryCenterOnUserOnce() {
    if (!_shouldCenterOnUser || !_isMapTabActive() || !_mapReady) return;
    _shouldCenterOnUser = false;
    final userPos = ref.read(userLocationProvider).position;
    _safeMoveMap(userPos, _defaultMapZoom);
  }

  void _safeMoveMap(LatLng center, double zoom) {
    if (!_mapReady) {
      _pendingCenter = center;
      _pendingZoom = zoom;
      return;
    }
    try {
      _mapController.move(center, zoom);
      _pendingCenter = null;
      _pendingZoom = null;
    } catch (_) {
      _mapReady = false;
      _pendingCenter = center;
      _pendingZoom = zoom;
    }
  }

  void _applyMapRotation(double headingDegrees, bool compassFollow) {
    if (!_mapReady) return;
    try {
      _mapController.rotate(compassFollow ? -headingDegrees : 0);
    } catch (_) {
      _mapReady = false;
    }
  }

  void _showRadiusHintBriefly() {
    if (!ref.read(mapUsesProximityRadiusProvider)) return;
    setState(() => _showRadiusHint = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showRadiusHint = false);
    });
  }

  BarrioMapCategory _zonaCategory(
    AlertEntity alert,
    List<UserZonaEntity> userZonas,
  ) => zonaCategoryForAlert(alert, userZonas);

  Future<void> _openFiltersSheet(MapState state) async {
    AlertLevel? selectedLevel = state.levelFilter;
    AlertSource? selectedSource = state.sourceFilter;
    String? selectedZonaId = state.zonaIdFilter;
    var selectedRadius = state.proximityRadiusMeters ?? 3000;
    final zonaChips = ref.read(mapZonaFilterChipsProvider);
    final usesProximity = ref.read(mapUsesProximityRadiusProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            Widget filterChip<T>({
              required String label,
              required T? value,
              required T? selectedValue,
              required ValueChanged<T?> onChanged,
            }) {
              final isSelected = value == null
                  ? selectedValue == null
                  : selectedValue == value;
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setStateSheet(() {
                    onChanged(selected ? value : null);
                  });
                },
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: AppConfig.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filtrar alertas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Zona',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tu zona principal y zonas suscritas',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: zonaChips.map((chip) {
                        final isSelected =
                            selectedZonaId == chip.value ||
                            (chip.value == null && selectedZonaId == null);
                        return FilterChip(
                          label: Text(chip.label),
                          selected: isSelected,
                          onSelected: (_) {
                            setStateSheet(() {
                              selectedZonaId = chip.value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    if (usesProximity) ...[
                      const Text(
                        'Cerca de ti',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Solo alertas a esta distancia de tu ubicación',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mapProximityRadiusOptions.map((meters) {
                          final km = meters ~/ 1000;
                          return FilterChip(
                            label: Text('$km km'),
                            selected: selectedRadius == meters,
                            onSelected: (_) {
                              setStateSheet(() => selectedRadius = meters);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const Text(
                      'Nivel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertLevel>(
                          label: 'Todos',
                          value: null,
                          selectedValue: selectedLevel,
                          onChanged: (value) => selectedLevel = value,
                        ),
                        filterChip<AlertLevel>(
                          label: 'Crítico',
                          value: AlertLevel.critico,
                          selectedValue: selectedLevel,
                          onChanged: (value) => selectedLevel = value,
                        ),
                        filterChip<AlertLevel>(
                          label: 'Urgente',
                          value: AlertLevel.urgente,
                          selectedValue: selectedLevel,
                          onChanged: (value) => selectedLevel = value,
                        ),
                        filterChip<AlertLevel>(
                          label: 'Preventivo',
                          value: AlertLevel.preventivo,
                          selectedValue: selectedLevel,
                          onChanged: (value) => selectedLevel = value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Fuente',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertSource>(
                          label: 'Todos',
                          value: null,
                          selectedValue: selectedSource,
                          onChanged: (value) => selectedSource = value,
                        ),
                        filterChip<AlertSource>(
                          label: 'Sensores',
                          value: AlertSource.sensor_audio,
                          selectedValue: selectedSource,
                          onChanged: (value) => selectedSource = value,
                        ),
                        filterChip<AlertSource>(
                          label: 'Ciudadanos',
                          value: AlertSource.ciudadano,
                          selectedValue: selectedSource,
                          onChanged: (value) => selectedSource = value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usesProximity
                          ? 'Visitante: filtras por distancia. Ciudadanos: por sus zonas.'
                          : 'Las zonas se muestran en el mapa según tu perfil.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              ref.read(mapProvider.notifier).clearFilters();
                              Navigator.pop(context);
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              ref.read(mapProvider.notifier).applyFilters(
                                    level: selectedLevel,
                                    clearLevelFilter: selectedLevel == null,
                                    source: selectedSource,
                                    clearSourceFilter: selectedSource == null,
                                    zonaIdFilter: selectedZonaId,
                                    clearZonaIdFilter: selectedZonaId == null,
                                    proximityRadiusMeters: usesProximity
                                        ? selectedRadius
                                        : null,
                                    clearProximityRadius: !usesProximity,
                                  );
                              Navigator.pop(context);
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _centerOnUser() {
    if (!_mapReady) return;
    try {
      final userPos = ref.read(userLocationProvider).position;
      _safeMoveMap(userPos, _mapController.camera.zoom);
    } catch (_) {
      _mapReady = false;
    }
  }

  void _toggleCompassFollow() {
    final heading = ref.read(userHeadingProvider);
    if (!heading.isAvailable) {
      AppAlert.warning(
        context,
        'Brújula no disponible en este dispositivo. Usa un celular físico.',
      );
      return;
    }
    ref.read(compassFollowModeProvider.notifier).toggle();
    final follow = ref.read(compassFollowModeProvider);
    _applyMapRotation(heading.headingDegrees, follow);
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    try {
      _mapController.move(
        _mapController.camera.center,
        _mapController.camera.zoom + delta,
      );
    } catch (_) {
      _mapReady = false;
    }
  }

  Future<void> _visitorGoBack() async {
    await ref.read(authProvider.notifier).logoutUser();
    if (mounted) context.go('/login');
  }

  Widget _visitorBackButton() {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: AppConfig.surface.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            elevation: 3,
            shadowColor: Colors.black45,
            child: IconButton(
              onPressed: _visitorGoBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Volver',
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _mapAppBarForUser({
    required bool isVisitor,
    required VoidCallback onRefresh,
    required VoidCallback onOpenFilters,
  }) {
    if (isVisitor) return null;
    return MapAppBar(
      onRefresh: onRefresh,
      onOpenFilters: onOpenFilters,
    );
  }

  Future<void> _openAlertSheet(
    AlertEntity summary,
    BarrioMapCategory category,
  ) async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context);
    final mapState = container.read(mapProvider);
    final position = mapState.positions[summary.id] ?? summary.position;
    final userPos = container.read(userLocationProvider).position;
    final detailFuture =
        container.read(mapProvider.notifier).loadAlertDetail(summary.id);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FutureBuilder<AlertEntity>(
          future: detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFF10131A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            final alert = snapshot.data ?? summary;
            final dist = position == null
                ? null
                : distanceToUserMeters(userPos, position);
            return AlertDetailSheet(
              alert: alert,
              barrioCategory: category,
              distanceFromUser: dist,
              position: position,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVisitor = ref.watch(authProvider).user?.isVisitor ?? false;
    final showProximityCircle = ref.watch(mapShowProximityCircleProvider);
    final mapSnapshot = ref.watch(
      mapProvider.select(
        (s) => (
          isLoading: s.isLoading,
          allAlertsEmpty: s.allAlerts.isEmpty,
          userZonasEmpty: s.userZonas.isEmpty,
          filteredEmpty: s.filteredAlerts.isEmpty,
          errorMessage: s.errorMessage,
          proximityRadiusMeters: s.proximityRadiusMeters,
        ),
      ),
    );
    final onRefresh = () => ref.read(mapProvider.notifier).refreshMapContext();
    final onOpenFilters = () => _openFiltersSheet(ref.read(mapProvider));
    final mapAppBar = _mapAppBarForUser(
      isVisitor: isVisitor,
      onRefresh: onRefresh,
      onOpenFilters: onOpenFilters,
    );

    ref.listen<LatLng>(mapProvider.select((state) => state.center), (
      previous,
      next,
    ) {
      if (previous == next) return;
      if (_shouldCenterOnUser) return;
      _safeMoveMap(next, _defaultMapZoom);
    });

    ref.listen(userLocationProvider, (previous, next) {
      if (_shouldCenterOnUser && !next.isLoading) {
        _tryCenterOnUserOnce();
      }
    });

    ref.listen(userHeadingProvider, (previous, next) {
      if (!next.isAvailable) return;
      final follow = ref.read(compassFollowModeProvider);
      _applyMapRotation(next.headingDegrees, follow);
    });

    ref.listen(compassFollowModeProvider, (previous, follow) {
      final heading = ref.read(userHeadingProvider);
      if (heading.isAvailable) {
        _applyMapRotation(heading.headingDegrees, follow);
      }
    });

    ref.listen<AlertEntity?>(lastSosAlertProvider, (previous, pending) {
      if (pending == null || pending.id == previous?.id) return;
      if (!_isMapTabActive()) return;
      _focusPendingSosIfAny();
    });

    ref.listen<MapState>(mapProvider, (previous, next) {
      if (!_isMapTabActive()) return;
      if (next.allAlerts.isEmpty) return;
      if (ref.read(lastSosAlertProvider) == null) return;
      if (previous?.allAlerts.isNotEmpty ?? false) return;
      _focusPendingSosIfAny();
    });

    if (mapSnapshot.isLoading &&
        mapSnapshot.allAlertsEmpty &&
        mapSnapshot.userZonasEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF10131A),
        appBar: mapAppBar,
        body: Stack(
          children: [
            const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (isVisitor) _visitorBackButton(),
          ],
        ),
      );
    }

    if (mapSnapshot.errorMessage.isNotEmpty &&
        mapSnapshot.allAlertsEmpty &&
        mapSnapshot.userZonasEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF10131A),
        appBar: mapAppBar,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  mapSnapshot.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            if (isVisitor) _visitorBackButton(),
          ],
        ),
      );
    }

    final hasMapContent =
        !mapSnapshot.filteredEmpty || !mapSnapshot.userZonasEmpty;

    if (!hasMapContent) {
      return Scaffold(
        backgroundColor: const Color(0xFF10131A),
        appBar: mapAppBar,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  mapSnapshot.errorMessage.isNotEmpty
                      ? mapSnapshot.errorMessage
                      : showProximityCircle
                          ? 'No hay alertas activas ni recientes (24 h) cerca de ti.'
                          : 'No hay alertas activas ni recientes (24 h) en tus zonas.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            if (isVisitor) _visitorBackButton(),
          ],
        ),
      );
    }

    final mapControlsBottom = 20.0;
    final headingAvailable = ref.watch(
      userHeadingProvider.select((s) => s.isAvailable),
    );
    final compassFollow = ref.watch(compassFollowModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      appBar: mapAppBar,
      body: Stack(
        children: [
          MapFlutterMapView(
            mapController: _mapController,
            tileProvider: _tileProvider,
            onMapReady: _onMapReady,
            onAlertTap: _openAlertSheet,
            initialZoom: _defaultMapZoom,
          ),
          Positioned(
            top: 4,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MapActiveFiltersBanner(
                onTap: onOpenFilters,
                onClear: () => ref.read(mapProvider.notifier).clearFilters(),
              ),
            ),
          ),
          if (isVisitor) _visitorBackButton(),
          if (showProximityCircle)
            Positioned(
              left: 12,
              bottom: mapControlsBottom + 56,
              child: AnimatedOpacity(
                opacity: _showRadiusHint ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_showRadiusHint,
                  child: RadiusHintChip(
                    radiusKm:
                        (mapSnapshot.proximityRadiusMeters ?? 3000) ~/ 1000,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: mapControlsBottom,
            right: 16,
            child: MapFloatingControls(
              compassActive: compassFollow && headingAvailable,
              compassAvailable: headingAvailable,
              onCompass: _toggleCompassFollow,
              onMyLocation: _centerOnUser,
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
              onFilter: isVisitor ? onOpenFilters : null,
            ),
          ),
        ],
      ),
    );
  }
}
