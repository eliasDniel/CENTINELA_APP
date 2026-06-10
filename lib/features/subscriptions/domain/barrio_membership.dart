// RF-0309: Clasificación de alertas en mapa por relación con el usuario
enum BarrioMapCategory {
  /// Barrio de registro — siempre tuyo.
  home,

  /// Hasta 3 barrios adicionales suscritos.
  subscribed,

  /// Otros barrios (visible si desactivas "Solo mis barrios").
  other,
}

BarrioMapCategory categorizeBarrio(
  String barrio, {
  required String? homeBarrio,
  required List<String> subscribed,
}) {
  if (homeBarrio != null && barrio == homeBarrio) {
    return BarrioMapCategory.home;
  }
  if (subscribed.contains(barrio)) {
    return BarrioMapCategory.subscribed;
  }
  return BarrioMapCategory.other;
}

String locationLabel({
  required String zona,
  required String barrio,
  BarrioMapCategory? category,
}) {
  if (barrio.isEmpty) return 'Zona · $zona';
  final cat = category;
  if (cat == BarrioMapCategory.home) return 'Tu barrio · $barrio';
  if (cat == BarrioMapCategory.subscribed) return 'Suscrito · $barrio';
  if (cat == BarrioMapCategory.other) return 'Otro barrio · $barrio';
  return '$zona · $barrio';
}

String barrioCategoryLabel(BarrioMapCategory category, String barrio) {
  if (barrio.isEmpty) return 'Zona completa';
  return switch (category) {
    BarrioMapCategory.home => 'Tu barrio',
    BarrioMapCategory.subscribed => 'Suscrito · $barrio',
    BarrioMapCategory.other => 'Otro barrio · $barrio',
  };
}
