// RF-0303: mapa OSM para ajustar ubicación del reporte
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../map/presentation/widgets/map_floating_controls.dart';

class ReportLocationMap extends ConsumerStatefulWidget {
  const ReportLocationMap({
    super.key,
    required this.position,
    required this.onPositionChanged,
  });

  final LatLng position;
  final ValueChanged<LatLng> onPositionChanged;

  @override
  ConsumerState<ReportLocationMap> createState() => _ReportLocationMapState();
}

class _ReportLocationMapState extends ConsumerState<ReportLocationMap> {
  final _mapController = MapController();
  bool _mapReady = false;
  bool _hasInitiallyCentered = false;

  static const _defaultZoom = 16.0;

  @override
  void didUpdateWidget(covariant ReportLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position && _mapReady) {
      _safeMove(widget.position, _mapController.camera.zoom);
    }
  }

  void _safeMove(LatLng center, double zoom) {
    if (!_mapReady) return;
    try {
      _mapController.move(center, zoom);
    } catch (_) {
      setState(() => _mapReady = false);
    }
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _mapReady = true);

    if (!_hasInitiallyCentered) {
      _hasInitiallyCentered = true;
      final userPosition = ref.read(userLocationProvider).position;
      widget.onPositionChanged(userPosition);
      _safeMove(userPosition, _defaultZoom);
      return;
    }

    _safeMove(widget.position, _mapController.camera.zoom);
  }

  void _centerOnUser() {
    if (!_mapReady) return;
    final userPosition = ref.read(userLocationProvider).position;
    widget.onPositionChanged(userPosition);
    _safeMove(userPosition, _mapController.camera.zoom);
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    try {
      _mapController.move(
        _mapController.camera.center,
        _mapController.camera.zoom + delta,
      );
    } catch (_) {
      setState(() => _mapReady = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = ref.watch(userLocationProvider).position;
    final mapCenter = _hasInitiallyCentered ? widget.position : userPosition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: AppConfig.primary),
            const SizedBox(width: 6),
            Text(
              'Ubicación del incidente',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Toca el mapa para mover el pin a la posición exacta.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppConfig.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: _defaultZoom,
                    onMapReady: _onMapReady,
                    onTap: (_, point) => widget.onPositionChanged(point),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.centinela.milagro',
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.position,
                          width: 40,
                          height: 40,
                          alignment: Alignment.bottomCenter,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppConfig.error,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: MapFloatingControls(
                    showCompass: false,
                    compassActive: false,
                    compassAvailable: false,
                    onCompass: () {},
                    onMyLocation: _centerOnUser,
                    onZoomIn: () => _zoomBy(1),
                    onZoomOut: () => _zoomBy(-1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppConfig.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConfig.border),
          ),
          child: Text(
            '${widget.position.latitude.toStringAsFixed(5)}, '
            '${widget.position.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
