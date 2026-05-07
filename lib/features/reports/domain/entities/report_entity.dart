// RF-0303, RF-0304, RF-0307, RF-0308: Report entity
class ReportEntity {
  final String id;
  final String type; // 'robo', 'accidente', 'sospechoso', 'daño_vial', 'otro'
  final String description;
  final double latitude;
  final double longitude;
  final String status; // 'recibido', 'en_revision', 'atendido'
  final DateTime timestamp;
  final String? userId; // null for reports from others
  final bool hasAttachment;
  final String barrio; // 'Norte', 'Sur', 'Centro', 'Este', 'Oeste'

  ReportEntity({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.timestamp,
    required this.barrio,
    this.userId,
    this.hasAttachment = false,
  });
}
