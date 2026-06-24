import 'package:latlong2/latlong.dart';

List<LatLng> parseWktPolygon(String? wkt) {
  if (wkt == null || wkt.isEmpty) return const [];

  final normalized = wkt.trim().toUpperCase();
  if (normalized.contains('EMPTY')) return const [];

  final match = RegExp(
    r'POLYGON\s*\(\(([^)]+)\)\)',
    caseSensitive: false,
  ).firstMatch(wkt);
  if (match == null) return const [];

  final pairs = match.group(1)!.split(',');
  final points = <LatLng>[];

  for (final pair in pairs) {
    final parts = pair.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final lng = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lng == null || lat == null) continue;
    points.add(LatLng(lat, lng));
  }

  return points;
}

LatLng? centerOfPoints(List<LatLng> points) {
  if (points.isEmpty) return null;
  var lat = 0.0;
  var lng = 0.0;
  for (final point in points) {
    lat += point.latitude;
    lng += point.longitude;
  }
  return LatLng(lat / points.length, lng / points.length);
}
