// Brújula del dispositivo: orientación al girar el teléfono
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserHeadingState {
  const UserHeadingState({
    this.headingDegrees = 0,
    this.isAvailable = false,
  });

  /// Grados desde el norte (0–360), sentido horario.
  final double headingDegrees;
  final bool isAvailable;
}

class UserHeadingNotifier extends Notifier<UserHeadingState> {
  StreamSubscription<CompassEvent>? _subscription;
  double _lastHeading = 0;

  @override
  UserHeadingState build() {
    ref.onDispose(() => _subscription?.cancel());

    if (kIsWeb) {
      return const UserHeadingState(isAvailable: false);
    }

    if (FlutterCompass.events == null) {
      return const UserHeadingState(isAvailable: false);
    }

    _subscription = FlutterCompass.events!.listen((event) {
      final raw = event.heading;
      if (raw == null) return;

      final smoothed = _smoothHeading(_lastHeading, raw);
      _lastHeading = smoothed;
      state = UserHeadingState(
        headingDegrees: smoothed,
        isAvailable: true,
      );
    });

    return const UserHeadingState();
  }

  double _smoothHeading(double previous, double next) {
    var delta = next - previous;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    if (delta.abs() < 1.5) return previous;
    var value = previous + delta * 0.35;
    if (value < 0) value += 360;
    if (value >= 360) value -= 360;
    return value;
  }
}

final userHeadingProvider =
    NotifierProvider<UserHeadingNotifier, UserHeadingState>(
  UserHeadingNotifier.new,
);

/// Si true, el mapa gira contigo (modo navegación) y el haz apunta adelante.
class CompassFollowModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final compassFollowModeProvider =
    NotifierProvider<CompassFollowModeNotifier, bool>(
  CompassFollowModeNotifier.new,
);

double headingToRadians(double degrees) => degrees * math.pi / 180;
