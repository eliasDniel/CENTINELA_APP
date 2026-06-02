// RF-0303: mapa OSM para ajustar ubicación del reporte
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/app_colors.dart';

class ReportLocationMap extends StatefulWidget {
  const ReportLocationMap({
    super.key,
    required this.position,
    required this.onPositionChanged,
  });

  final LatLng position;
  final ValueChanged<LatLng> onPositionChanged;

  @override
  State<ReportLocationMap> createState() => _ReportLocationMapState();
}

class _ReportLocationMapState extends State<ReportLocationMap> {
  final _mapController = MapController();

  @override
  void didUpdateWidget(covariant ReportLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _mapController.move(widget.position, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            height: 200,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.position,
                initialZoom: 16,
                onTap: (_, point) => widget.onPositionChanged(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.centinela.milagro',
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.position,
                      width: 40,
                      height: 40,
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
