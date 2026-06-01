// RF-0306: página del mapa accesible sin autenticación
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscriptions/domain/barrio_membership.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';
import '../widgets/map_active_filters_banner.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../../reports/presentation/providers/sos_provider.dart';
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
    final category = ref.read(barrioCategoryFnProvider)(alert.barrio);
    _openAlertSheet(alert, category);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          content: Text(
            'Gira el teléfono: el haz azul muestra hacia dónde miras. '
            'Toca la brújula para activar o desactivar.',
          ),
        ),
      );
    });
  }

  void _applyMapRotation(double headingDegrees, bool compassFollow) {
    try {
      _mapController.rotate(compassFollow ? -headingDegrees : 0);
    } catch (_) {
      // Mapa aún no montado
    }
  }

  void _showRadiusHintBriefly() {
    if (!ref.read(mapUsesProximityRadiusProvider)) return;
    setState(() => _showRadiusHint = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showRadiusHint = false);
    });
  }

  Future<void> _openFiltersSheet(MapState state) async {
    AlertLevel? selectedLevel = state.levelFilter;
    AlertSource? selectedSource = state.sourceFilter;
    String? selectedBarrio = state.barrioFilter;
    var selectedRadius = state.proximityRadiusMeters ?? 3000;
    final barrioChips = ref.read(mapBarrioFilterChipsProvider);
    final showBarrioFilter = ref.read(showMapBarrioFilterProvider);
    final usesProximity = ref.read(mapUsesProximityRadiusProvider);
    final isLoggedIn = !(ref.read(authProvider).user?.isVisitor ?? true) &&
        ref.read(authProvider).user != null;

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
              final isSelected = value == null ? selectedValue == null : selectedValue == value;
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
                    if (showBarrioFilter) ...[
                      const Text(
                        'Barrio',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLoggedIn
                            ? 'Solo barrios a los que estás suscrito'
                            : 'Explorar por zona',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: barrioChips.map((chip) {
                          final isSelected = selectedBarrio == chip.value;
                          return FilterChip(
                            label: Text(chip.label),
                            selected: isSelected,
                            onSelected: (_) {
                              setStateSheet(() => selectedBarrio = chip.value);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const Text('Nivel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertLevel>(label: 'Todos', value: null, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Vigilancia', value: AlertLevel.vigilancia, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Alerta', value: AlertLevel.alerta, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Emergencia', value: AlertLevel.emergencia, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Fuente', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertSource>(label: 'Todos', value: null, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                        filterChip<AlertSource>(label: 'Sensores IoT', value: AlertSource.sensor_audio, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                        filterChip<AlertSource>(label: 'Ciudadanos', value: AlertSource.ciudadano, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usesProximity
                          ? 'Visitante: filtras por distancia. Ciudadanos: por barrio sin límite km.'
                          : 'Pin: letra = nivel (E/A/V). Borde = tu barrio o suscrito.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ref.read(mapProvider.notifier).applyFilters(
                                level: selectedLevel,
                                source: selectedSource,
                                barrioFilter:
                                    showBarrioFilter ? selectedBarrio : null,
                                clearBarrioFilter: !showBarrioFilter ||
                                    selectedBarrio == null,
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
              ),
            );
          },
        );
      },
    );
  }

  void _centerOnUser() {
    final userPos = ref.read(userLocationProvider).position;
    _mapController.move(userPos, _mapController.camera.zoom);
  }

  void _toggleCompassFollow() {
    ref.read(compassFollowModeProvider.notifier).toggle();
    final follow = ref.read(compassFollowModeProvider);
    final heading = ref.read(userHeadingProvider);
    if (!heading.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Brújula no disponible en este dispositivo. Usa un celular físico.',
          ),
        ),
      );
      return;
    }
    _applyMapRotation(heading.headingDegrees, follow);
  }

  void _openAlertSheet(MapAlertEntity alert, BarrioMapCategory category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final dist = distanceToUserMeters(
          ref.read(userLocationProvider).position,
          alert.position,
        );
        return AlertDetailSheet(
          alert: alert,
          barrioCategory: category,
          distanceFromUser: dist,
          onCenterMap: () {
            Navigator.pop(context);
            ref.read(mapProvider.notifier).centerOnAlert(alert);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    ref.listen<MapAlertEntity?>(
      mapProvider.select((state) => state.lastIncomingAlert),
      (previous, next) {
        if (next == null || next.id == previous?.id) return;
        // La SOS del propio usuario ya tiene confirmación en Inicio.
        if (next.type == AlertType.sos) return;
        final monitored = ref.read(monitoredBarriosProvider);
        final barrioFilter = ref.read(
          mapProvider.select((s) => s.barrioFilter),
        );
        if (barrioFilter != null && next.barrio != barrioFilter) return;
        if (barrioFilter == null &&
            monitored.isNotEmpty &&
            !monitored.contains(next.barrio)) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Nueva alerta en ${next.barrio}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );

    ref.listen<LatLng>(
      mapProvider.select((state) => state.center),
      (previous, next) {
        _mapController.move(next, 14.2);
      },
    );

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

    ref.listen<MapAlertEntity?>(lastSosAlertProvider, (previous, pending) {
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

    if (state.allAlerts.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF10131A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final userLocation = ref.watch(userLocationProvider);
    final heading = ref.watch(userHeadingProvider);
    final compassFollow = ref.watch(compassFollowModeProvider);
    final proximityCenter = state.proximityRadiusMeters != null
        ? userLocation.position
        : state.center;
    final categorize = ref.watch(barrioCategoryFnProvider);
    final markers = state.filteredAlerts.map((alert) {
      final category = categorize(alert.barrio);
      final hasCaption = category != BarrioMapCategory.other;
      return Marker(
        width: 48,
        height: hasCaption ? 80 : 50,
        alignment: Alignment.topCenter,
        point: alert.position,
        child: AlertMarkerWidget(
          alert: alert,
          barrioCategory: category,
          onTap: () => _openAlertSheet(alert, category),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Alertas Activas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          
          IconButton(
            onPressed: () => _openFiltersSheet(state),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrar alertas',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation.position,
              initialZoom: 14.2,
              interactionOptions: InteractionOptions(
                flags: compassFollow && heading.isAvailable
                    ? InteractiveFlag.all & ~InteractiveFlag.rotate
                    : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.barrioseguro.app',
                tileProvider: NetworkTileProvider(),
              ),
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
            top: 8,
            left: 12,
            right: 12,
            child: MapActiveFiltersBanner(
              onTap: () => _openFiltersSheet(state),
            ),
          ),
          if (state.proximityRadiusMeters != null)
            Positioned(
              left: 12,
              bottom: 24,
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
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'compass_follow',
                  backgroundColor: compassFollow && heading.isAvailable
                      ? const Color(0xFF5C6BC0)
                      : AppConfig.surface,
                  onPressed: _toggleCompassFollow,
                  tooltip: 'Modo brújula',
                  child: Icon(
                    Icons.explore,
                    color: heading.isAvailable
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'my_location',
                  backgroundColor: const Color(0xFF42A5F5),
                  onPressed: _centerOnUser,
                  tooltip: 'Centrar en mí',
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  backgroundColor: AppConfig.primaryDark,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  backgroundColor: AppConfig.primary,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
