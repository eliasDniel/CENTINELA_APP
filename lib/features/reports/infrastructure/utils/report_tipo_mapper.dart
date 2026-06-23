/// Mapeo entre tipos de la UI y tipos del backend (ms-core).
class ReportTipoMapper {
  const ReportTipoMapper._();

  static String uiToApi(String uiType) {
    return switch (uiType) {
      'robo' || 'sicariato' || 'accidente' => 'incidente',
      'sospechoso' => 'sospechoso',
      'panico' || 'sos' => 'panico',
      _ => 'otro',
    };
  }

  static String apiToUi(String apiTipo, {String descripcion = ''}) {
    return switch (apiTipo) {
      'panico' => 'sicariato',
      'sospechoso' => 'sospechoso',
      'incidente' => _incidentUiFromDescription(descripcion),
      _ => apiTipo,
    };
  }

  static String _incidentUiFromDescription(String descripcion) {
    final text = descripcion.toLowerCase();
    if (text.contains('accidente')) return 'accidente';
    if (text.contains('robo')) return 'robo';
    if (text.contains('sicariato')) return 'sicariato';
    return 'robo';
  }
}
