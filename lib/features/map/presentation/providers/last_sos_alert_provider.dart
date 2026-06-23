import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/map_alert_entity.dart';

/// SOS recién enviado que el mapa debe enfocar al abrir la pestaña.
final lastSosAlertProvider = StateProvider<AlertEntity?>((ref) => null);
