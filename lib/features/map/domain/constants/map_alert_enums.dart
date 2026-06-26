/// Tipos soportados por CENTINELA: IA (disparo/grito) y reportes ciudadanos.
enum AlertType {
  disparo,
  grito,
  reporte_ciudadano,
  sos,
}

enum AlertSource {
  sensor_audio,
  ciudadano,
}

enum AlertLevel {
  preventivo,
  urgente,
  critico,
}
