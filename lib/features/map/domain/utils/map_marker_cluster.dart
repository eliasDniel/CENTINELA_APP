import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../constants/map_alert_enums.dart';
import '../entities/map_alert_entity.dart';
import '../entities/map_alert_extensions.dart';

/// Agrupa marcadores cuando hay zoom bajo o muchas alertas visibles.
class MapMarkerCluster {
  const MapMarkerCluster({
    required this.center,
    required this.alerts,
  });

  final LatLng center;
  final List<AlertEntity> alerts;

  bool get isCluster => alerts.length > 1;

  AlertLevel get dominantLevel {
    var maxSeverity = -1;
    AlertLevel level = AlertLevel.preventivo;
    for (final alert in alerts) {
      if (alert.severidad > maxSeverity) {
        maxSeverity = alert.severidad;
        level = alert.level;
      }
    }
    return level;
  }
}

bool shouldClusterMapMarkers({
  required double zoom,
  required int alertCount,
}) {
  if (alertCount <= 12) return false;
  return zoom < 14.5;
}

bool shouldUseCompactMarkers({
  required double zoom,
  required int alertCount,
}) {
  if (alertCount <= 20) return zoom < 13;
  return zoom < 14;
}

double cellSizeDegreesForZoom(double zoom) {
  final scale = math.pow(2, zoom.clamp(8, 18));
  return 360 / (256 * scale) * 72;
}

List<MapMarkerCluster> clusterMapAlerts({
  required List<AlertEntity> alerts,
  required Map<String, LatLng> positions,
  required double zoom,
}) {
  if (!shouldClusterMapMarkers(zoom: zoom, alertCount: alerts.length)) {
    final singles = <MapMarkerCluster>[];
    for (final alert in alerts) {
      final point = positions[alert.id];
      if (point == null) continue;
      singles.add(MapMarkerCluster(center: point, alerts: [alert]));
    }
    return singles;
  }

  final cellSize = cellSizeDegreesForZoom(zoom);
  final buckets = <String, List<AlertEntity>>{};
  final centers = <String, LatLng>{};

  for (final alert in alerts) {
    final point = positions[alert.id];
    if (point == null) continue;

    final cellX = (point.longitude / cellSize).floor();
    final cellY = (point.latitude / cellSize).floor();
    final key = '$cellX:$cellY';

    buckets.putIfAbsent(key, () => []).add(alert);
    centers[key] = centers.containsKey(key)
        ? LatLng(
            (centers[key]!.latitude + point.latitude) / 2,
            (centers[key]!.longitude + point.longitude) / 2,
          )
        : point;
  }

  return buckets.entries
      .map(
        (entry) => MapMarkerCluster(
          center: centers[entry.key]!,
          alerts: entry.value,
        ),
      )
      .toList();
}
