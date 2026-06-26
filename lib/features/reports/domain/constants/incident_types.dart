// RF-0303: etiquetas de tipos de incidente
import 'package:flutter/material.dart';

import 'package:centinela_milagro/core/utils/app_colors.dart';

const kIncidentTypes = <Map<String, String>>[
  {'label': 'Homicidio / Sicariato','value': 'HOMICIDIO_SICARIATO'},
  {'label': 'Secuestro',            'value': 'SECUESTRO'},
  {'label': 'Robo',                 'value': 'ROBO'},
  {'label': 'Extorsión',            'value': 'EXTORSION'},
  {'label': 'Persona sospechosa',   'value': 'PERSONA_SOSPECHOSA'},
  {'label': 'Vehículo sospechoso',  'value': 'VEHICULO_SOSPECHOSO'},
];

const kPanicIncidentType = 'PANICO';

bool isKnownIncidentType(String? value) {
  if (value == null || value.isEmpty) return false;
  final normalized = value.trim().toUpperCase();
  if (normalized == kPanicIncidentType) return true;
  return kIncidentTypes.any((t) => t['value'] == normalized);
}

String incidentTypeLabel(String? value) {
  if (value == null) return 'N/A';
  if (value == 'PANICO') return 'Pánico';
  for (final t in kIncidentTypes) {
    if (t['value'] == value) return t['label']!;
  }
  return value.replaceAll('_', ' ');
}

IconData incidentTypeIcon(String type) {
  return switch (type) {
    'PANICO'              => Icons.sos_rounded,
    'HOMICIDIO_SICARIATO' => Icons.dangerous_rounded,
    'SECUESTRO'           => Icons.lock_person_rounded,
    'ROBO'                => Icons.no_backpack_rounded,
    'EXTORSION'           => Icons.money_off_rounded,
    'PERSONA_SOSPECHOSA'  => Icons.person_search_rounded,
    'VEHICULO_SOSPECHOSO' => Icons.directions_car_rounded,
    _                     => Icons.report_rounded,
  };
}

Color incidentTypeColor(String type) {
  return switch (type) {
    'PANICO'              => AppConfig.sos,
    'HOMICIDIO_SICARIATO' => AppConfig.sos,
    'SECUESTRO'           => AppConfig.sos,
    'ROBO'                => AppConfig.warning,
    'EXTORSION'           => AppConfig.warning,
    'PERSONA_SOSPECHOSA'  => AppConfig.primary,
    'VEHICULO_SOSPECHOSO' => AppConfig.primary,
    _                     => AppConfig.textTertiary,
  };
}