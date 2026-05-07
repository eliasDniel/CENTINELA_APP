// RF-0303, RF-0304: Report model for infrastructure layer
import '../../domain/entities/report_entity.dart';

class ReportModel {
  final String id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime timestamp;
  final String? userId;
  final bool hasAttachment;
  final String barrio;

  ReportModel({
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

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      barrio: json['barrio'] as String? ?? 'Centro',
      userId: json['userId'] as String?,
      hasAttachment: json['hasAttachment'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'barrio': barrio,
      'userId': userId,
      'hasAttachment': hasAttachment,
    };
  }

  ReportEntity toEntity() {
    return ReportEntity(
      id: id,
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      status: status,
      timestamp: timestamp,
      barrio: barrio,
      userId: userId,
      hasAttachment: hasAttachment,
    );
  }

  static ReportModel fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      type: entity.type,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      status: entity.status,
      timestamp: entity.timestamp,
      barrio: entity.barrio,
      userId: entity.userId,
      hasAttachment: entity.hasAttachment,
    );
  }
}
