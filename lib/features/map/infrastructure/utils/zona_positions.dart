import 'package:latlong2/latlong.dart';

/// Centroides aproximados para pintar alertas sin coordenadas exactas.
const kZonaPositions = <String, LatLng>{
  'Milagro': LatLng(-2.1344, -79.5874),
  'Chobo': LatLng(-2.1480, -79.5750),
  'Mariscal Sucre': LatLng(-2.1520, -79.5680),
  'Roberto Astudillo': LatLng(-2.1280, -79.5780),
};

LatLng zonaFallbackPosition(String? zonaNombre, {String seed = ''}) {
  if (zonaNombre != null && kZonaPositions.containsKey(zonaNombre)) {
    return kZonaPositions[zonaNombre]!;
  }
  final hash = seed.isEmpty ? 0 : seed.codeUnits.fold<int>(0, (a, b) => a + b);
  final offset = (hash % 100) / 10000;
  return LatLng(-2.1344 + offset, -79.5874 - offset);
}
