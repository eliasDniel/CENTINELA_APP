/// Ventana temporal del mapa: solo alertas creadas en las últimas N horas.
const kMapAlertWindowHours = 24;

bool matchesCitizenMapWindow({
  required DateTime createdAt,
  int windowHours = kMapAlertWindowHours,
}) {
  final cutoff = DateTime.now().subtract(Duration(hours: windowHours));
  return !createdAt.isBefore(cutoff);
}

/// Activa sin límite de tiempo, o creada en las últimas [windowHours].
bool isEligibleForCitizenMap({
  required String estado,
  required DateTime createdAt,
  int windowHours = kMapAlertWindowHours,
}) {
  if (estado == 'activa') return true;
  return matchesCitizenMapWindow(
    createdAt: createdAt,
    windowHours: windowHours,
  );
}
