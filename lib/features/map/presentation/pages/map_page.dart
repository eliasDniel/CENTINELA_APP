// RF-0306: página del mapa accesible sin autenticación
import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../subscriptions/domain/barrio_membership.dart';
import '../widgets/map_floating_controls.dart';
import '../widgets/map_active_filters_banner.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../../domain/utils/wkt_polygon_parser.dart';
import '../providers/last_sos_alert_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/alert_detail_sheet.dart';
import '../widgets/alert_marker_widget.dart';
import '../../../../core/location/user_heading_provider.dart';
import '../../../../core/location/user_location_provider.dart';
import '../widgets/radius_badge_widget.dart';
import '../widgets/user_location_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();
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
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final heading = ref.read(userHeadingProvider);
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
  ) {
    if (userZonas.isEmpty) return BarrioMapCategory.other;

    final alertZonaId = alert.zonaId ?? alert.zona?.id;
    UserZonaEntity? match;
    if (alertZonaId != null && alertZonaId.isNotEmpty) {
      for (final zone in userZonas) {
        if (zone.zonaId == alertZonaId) {
          match = zone;
          break;
        }
      }
    }
    match ??= userZonas
        .where((zone) => zone.zona.nombre == alert.zonaNombre)
        .firstOrNull;

    if (match == null) return BarrioMapCategory.other;
    if (match.isPrincipal) return BarrioMapCategory.home;
    return BarrioMapCategory.subscribed;
  }

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

  PreferredSizeWidget _buildMapAppBar({
    required MapState state,
    required VoidCallback onRefresh,
    required VoidCallback onOpenFilters,
  }) {
    final hasActiveFilters = ref.watch(mapHasActiveFiltersProvider);
    final alertCount = state.filteredAlerts.length;

    return AppBar(
      backgroundColor: AppConfig.surface.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mapa de alertas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            '$alertCount alerta${alertCount == 1 ? '' : 's'} activa${alertCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppConfig.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: state.isLoading ? null : onRefresh,
          icon: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar alertas',
        ),
        IconButton(
          onPressed: onOpenFilters,
          tooltip: 'Filtrar alertas',
          icon: Badge(
            isLabelVisible: hasActiveFilters,
            smallSize: 8,
            backgroundColor: AppConfig.sos,
            child: const Icon(Icons.tune_rounded),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> _openAlertSheet(
    AlertEntity summary,
    BarrioMapCategory category,
  ) async {
    final state = ref.read(mapProvider);
    final position = state.positions[summary.id] ?? summary.position;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FutureBuilder<AlertEntity>(
          future: ref.read(mapProvider.notifier).loadAlertDetail(summary.id),
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
                : distanceToUserMeters(
                    ref.read(userLocationProvider).position,
                    position,
                  );
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
    final state = ref.watch(mapProvider);

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

    if (state.isLoading && state.allAlerts.isEmpty && state.userZonas.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF10131A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.errorMessage.isNotEmpty &&
        state.allAlerts.isEmpty &&
        state.userZonas.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF10131A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final hasMapContent =
        state.filteredAlerts.isNotEmpty || state.userZonas.isNotEmpty;

    if (!hasMapContent) {
      return Scaffold(
        backgroundColor: const Color(0xFF10131A),
        appBar: _buildMapAppBar(
          state: state,
          onRefresh: () => ref.read(mapProvider.notifier).refreshAlerts(),
          onOpenFilters: () => _openFiltersSheet(state),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'No hay alertas activas en tus zonas.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final userLocation = ref.watch(userLocationProvider);
    final heading = ref.watch(userHeadingProvider);
    final compassFollow = ref.watch(compassFollowModeProvider);
    final mapControlsBottom = 20.0;
    final proximityCenter = state.proximityRadiusMeters != null
        ? userLocation.position
        : state.center;
    final categorize = (AlertEntity alert) =>
        _zonaCategory(alert, state.userZonas);
    final zonePolygons = <Polygon>[];
    for (final userZona in state.userZonas) {
      final points = parseWktPolygon(userZona.zona.geomWkt);
      if (points.isEmpty) continue;
      final isSelected =
          state.zonaIdFilter == null || state.zonaIdFilter == userZona.zonaId;
      final baseColor = userZona.isPrincipal
          ? const Color(0xFF42A5F5)
          : const Color(0xFF66BB6A);
      zonePolygons.add(
        Polygon(
          points: points,
          color: baseColor.withOpacity(isSelected ? 0.18 : 0.08),
          borderColor: baseColor.withOpacity(isSelected ? 0.9 : 0.35),
          borderStrokeWidth: isSelected ? 2.5 : 1.2,
        ),
      );
    }
    final markers = state.filteredAlerts.map((alert) {
      final position = state.positions[alert.id];
      if (position == null) return null;
      final category = categorize(alert);
      return Marker(
        width: kAlertMarkerWidth,
        height: kAlertMarkerHeight,
        alignment: Marker.computePixelAlignment(
          width: kAlertMarkerWidth,
          height: kAlertMarkerHeight,
          left: kAlertPinTipLeft,
          top: kAlertPinTipTop,
        ),
        point: position,
        child: AlertMarkerWidget(
          alert: alert,
          barrioCategory: category,
          onTap: () => _openAlertSheet(alert, category),
        ),
      );
    }).whereType<Marker>().toList();

    return Scaffold(
      appBar: _buildMapAppBar(
        state: state,
        onRefresh: () => ref.read(mapProvider.notifier).refreshAlerts(),
        onOpenFilters: () => _openFiltersSheet(state),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation.position,
              initialZoom: _defaultMapZoom,
              onMapReady: _onMapReady,
              interactionOptions: InteractionOptions(
                flags: compassFollow && heading.isAvailable
                    ? InteractiveFlag.all & ~InteractiveFlag.rotate
                    : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.barrioseguro.app',
                retinaMode: RetinaMode.isHighDensity(context),
                tileProvider: NetworkTileProvider(),
              ),
              if (zonePolygons.isNotEmpty) PolygonLayer(polygons: zonePolygons),
              if (state.proximityRadiusMeters != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: proximityCenter,
                      radius: state.proximityRadiusMeters!.toDouble(),
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.08),
                      borderColor: const Color(0xFF1E90FF),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation.position,
                    width: heading.isAvailable ? 72 : 28,
                    height: heading.isAvailable ? 72 : 28,
                    alignment: Alignment.center,
                    child: UserLocationMarker(
                      headingDegrees: heading.headingDegrees,
                      beamPointsUpOnScreen:
                          compassFollow && heading.isAvailable,
                      showBeam: heading.isAvailable,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 4,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MapActiveFiltersBanner(
                onTap: () => _openFiltersSheet(state),
                onClear: () => ref.read(mapProvider.notifier).clearFilters(),
              ),
            ),
          ),
          if (state.proximityRadiusMeters != null)
            Positioned(
              left: 12,
              bottom: mapControlsBottom + 56,
              child: AnimatedOpacity(
                opacity: _showRadiusHint ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_showRadiusHint,
                  child: RadiusHintChip(
                    radiusKm: state.proximityRadiusMeters! ~/ 1000,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: mapControlsBottom,
            right: 16,
            child: MapFloatingControls(
              compassActive: compassFollow && heading.isAvailable,
              compassAvailable: heading.isAvailable,
              onCompass: _toggleCompassFollow,
              onMyLocation: _centerOnUser,
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
            ),
          ),
        ],
      ),
    );
  }
}
