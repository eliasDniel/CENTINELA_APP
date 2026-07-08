/// Ventana temporal del mapa: solo alertas creadas en las últimas N horas.
const kMapAlertWindowHours = 24;

bool matchesCitizenMapWindow({
  required DateTime createdAt,
  int windowHours = kMapAlertWindowHours,
}) {
  final cutoff = DateTime.now().subtract(Duration(hours: windowHours));
  return !createdAt.isBefore(cutoff);
}

/// Misma regla que el backend `/alertas/mapa`: solo últimas [windowHours].
bool isEligibleForCitizenMap({
  required DateTime createdAt,
  int windowHours = kMapAlertWindowHours,
}) {
  return matchesCitizenMapWindow(
    createdAt: createdAt,
    windowHours: windowHours,
  );
}
