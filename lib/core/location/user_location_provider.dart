// Ubicación del usuario (prototipo: punto fijo en Milagro; producción: GPS)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Centro de referencia del cantón (mapa y radio visitante).
const milagroMapCenter = LatLng(-2.1344, -79.5874);

class UserLocation {
  const UserLocation({
    required this.position,
    required this.shortAddress,
  });

  final LatLng position;
  final String shortAddress;
}

final userLocationProvider = Provider<UserLocation>((ref) {
  return const UserLocation(
    position: LatLng(-2.1368, -79.5892),
    shortAddress: 'Av. 4 de Noviembre · Milagro, Ecuador',
  );
});

/// Distancia en metros entre el usuario y un punto.
double distanceToUserMeters(LatLng user, LatLng target) {
  const distance = Distance();
  return distance.as(LengthUnit.Meter, user, target);
}

String formatDistanceMeters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
