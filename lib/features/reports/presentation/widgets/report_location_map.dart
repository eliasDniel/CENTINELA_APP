// RF-0303: mapa OSM para ajustar ubicación del reporte
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../map/presentation/widgets/map_floating_controls.dart';

/// Radio máximo permitido (metros) entre el GPS del usuario y el pin del reporte.
const kReportLocationMaxRadiusMeters = 100.0;

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

  /// Tamaño del marcador (debe coincidir con [Icon.size]).
  static const _pinSize = 40.0;

  /// Punta de [Icons.location_pin] en la cuadrícula Material 24×24: (12, 22).
  /// Ancla el LatLng en esa punta, no en el centro ni en el borde del widget.
  static final _pinTipAlignment = Marker.computePixelAlignment(
    width: _pinSize,
    height: _pinSize,
    left: _pinSize * 12 / 24,
    top: _pinSize * 22 / 24,
  );

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

  void _trySetPosition(LatLng point, LatLng userPosition) {
    final meters = distanceToUserMeters(userPosition, point);
    if (meters > kReportLocationMaxRadiusMeters) {
      AppAlert.warning(
        context,
        'Solo puedes ubicar el reporte dentro de un radio de '
        '${kReportLocationMaxRadiusMeters.round()} m desde tu posición actual.',
      );
      return;
    }
    widget.onPositionChanged(point);
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConfig.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppConfig.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 18,
                color: AppConfig.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Por tu seguridad, evita marcar tu ubicación exacta. Selecciona un punto aproximado dentro de la zona del incidente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.textPrimary,
                        height: 1.35,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca el mapa para mover el pin. Solo dentro del círculo de '
          '${kReportLocationMaxRadiusMeters.round()} m alrededor de tu GPS.',
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
                    onTap: (_, point) => _trySetPosition(point, userPosition),
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
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: userPosition,
                          radius: kReportLocationMaxRadiusMeters,
                          useRadiusInMeter: true,
                          color: AppConfig.primary.withValues(alpha: 0.12),
                          borderColor: AppConfig.primary,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.position,
                          width: _pinSize,
                          height: _pinSize,
                          alignment: _pinTipAlignment,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppConfig.error,
                            size: _pinSize,
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
