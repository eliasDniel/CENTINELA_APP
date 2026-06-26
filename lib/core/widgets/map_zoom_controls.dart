import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/app_colors.dart';

class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.mapController,
    this.mapReady = true,
    this.onCenterOnUser,
    this.showCenterOnUser = false,
    this.heroTagPrefix = 'map_zoom',
  });

  final MapController mapController;
  final bool mapReady;
  final VoidCallback? onCenterOnUser;
  final bool showCenterOnUser;
  final String heroTagPrefix;

  void _zoomBy(double delta) {
    if (!mapReady) return;
    try {
      mapController.move(
        mapController.camera.center,
        mapController.camera.zoom + delta,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        if (showCenterOnUser && onCenterOnUser != null)
          FloatingActionButton(
            mini: true,
            heroTag: '${heroTagPrefix}_my_location',
            backgroundColor: const Color(0xFF42A5F5),
            onPressed: onCenterOnUser,
            tooltip: 'Centrar en mí',
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        FloatingActionButton(
          mini: true,
          heroTag: '${heroTagPrefix}_zoom_in',
          backgroundColor: AppConfig.primaryDark,
          onPressed: () => _zoomBy(1),
          tooltip: 'Acercar',
          child: const Icon(Icons.add, color: Colors.white),
        ),
        FloatingActionButton(
          mini: true,
          heroTag: '${heroTagPrefix}_zoom_out',
          backgroundColor: AppConfig.primaryDark,
          onPressed: () => _zoomBy(-1),
          tooltip: 'Alejar',
          child: const Icon(Icons.remove, color: Colors.white),
        ),
      ],
    );
  }
}
