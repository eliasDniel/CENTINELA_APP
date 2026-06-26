import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UserLocationService {
  const UserLocationService._();

  static Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  static Future<LatLng?> getCurrentLatLng() async {
    if (!await ensurePermission()) return null;
    if (!await isServiceEnabled()) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  static Stream<LatLng> watchLatLng({int distanceFilterMeters = 8}) async* {
    if (!await ensurePermission()) return;
    if (!await isServiceEnabled()) return;

    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }
}
