// RF-0303: etiquetas de tipos de incidente
import 'package:flutter/material.dart';

import 'package:centinela_milagro/core/utils/app_colors.dart';
const kIncidentTypes = <Map<String, String>>[
  {'label': 'Robo', 'value': 'robo'},
  {'label': 'Sicariato', 'value': 'sicariato'},
  {'label': 'Sospechoso', 'value': 'sospechoso'},
  {'label': 'Accidente', 'value': 'accidente'},
];

String incidentTypeLabel(String? value) {
  if (value == null) return 'N/A';
  for (final t in kIncidentTypes) {
    if (t['value'] == value) return t['label']!;
  }
  return value.replaceAll('_', ' ');
}

IconData incidentTypeIcon(String type) {
  return switch (type) {
    'robo' => Icons.no_backpack_rounded,
    'accidente' => Icons.car_crash_rounded,
    'sospechoso' => Icons.person_search_rounded,
    'sicariato' => Icons.dangerous_outlined,
    _ => Icons.report_rounded,
  };
}

Color incidentTypeColor(String type) {
  return switch (type) {
    'robo' => AppConfig.success,
    'accidente' => AppConfig.warning,
    'sospechoso' => AppConfig.primary,
    'sicariato' => AppConfig.sos,
    _ => AppConfig.textTertiary,
  };
}
