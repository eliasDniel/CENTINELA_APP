import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'user_location_service.dart';

/// Centro de referencia del cantón (fallback si GPS no está disponible).
const milagroMapCenter = LatLng(-2.1344, -79.5874);

class UserLocation {
  const UserLocation({
    required this.position,
    required this.isGps,
    required this.isLoading,
  });

  final LatLng position;
  final bool isGps;
  final bool isLoading;

  factory UserLocation.fallback({bool isLoading = false}) {
    return UserLocation(
      position: milagroMapCenter,
      isGps: false,
      isLoading: isLoading,
    );
  }
}

class UserLocationNotifier extends Notifier<UserLocation> {
  StreamSubscription<LatLng>? _subscription;

  @override
  UserLocation build() {
    ref.onDispose(() => _subscription?.cancel());
    Future.microtask(_startTracking);
    return UserLocation.fallback(isLoading: true);
  }

  Future<void> refresh() async {
    await _subscription?.cancel();
    _subscription = null;
    await _startTracking();
  }

  Future<void> _startTracking() async {
    state = UserLocation.fallback(isLoading: true);

    try {
      final current = await UserLocationService.getCurrentLatLng();
      if (!ref.mounted) return;

      if (current != null) {
        state = UserLocation(
          position: current,
          isGps: true,
          isLoading: false,
        );
      } else {
        state = UserLocation.fallback();
      }

      _subscription = UserLocationService.watchLatLng().listen(
        (position) {
          if (!ref.mounted) return;
          state = UserLocation(
            position: position,
            isGps: true,
            isLoading: false,
          );
        },
        onError: (_) {},
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = UserLocation.fallback();
    }
  }
}

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation>(
  UserLocationNotifier.new,
);

/// Distancia en metros entre el usuario y un punto.
double distanceToUserMeters(LatLng user, LatLng target) {
  const distance = Distance();
  return distance.as(LengthUnit.Meter, user, target);
}

String formatDistanceMeters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
