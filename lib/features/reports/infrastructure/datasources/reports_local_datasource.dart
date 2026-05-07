// RF-0303, RF-0304: Mock local reports data source
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';

class ReportsLocalDataSource {
  // RF-0307: Mock neighborhood reports (visible to all) - 8 reportes distribuidos
  final List<ReportModel> _neighborhoodReports = [
    // Emergencias (tipo robo) - barrios diversos
    ReportModel(
      id: '1',
      type: 'robo',
      description: 'Asalto en la esquina de Central y 5ta',
      latitude: -2.1234,
      longitude: -79.5678,
      status: 'atendido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      userId: null,
      hasAttachment: false,
      barrio: 'Norte',
    ),
    ReportModel(
      id: '2',
      type: 'robo',
      description: 'Intento de robo en almacén comercial',
      latitude: -2.1300,
      longitude: -79.5600,
      status: 'en_revision',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      userId: null,
      hasAttachment: false,
      barrio: 'Centro',
    ),
    // Alertas (accidentes y sospechosos)
    ReportModel(
      id: '3',
      type: 'accidente',
      description: 'Choque frontal en Avenida Principal',
      latitude: -2.1250,
      longitude: -79.5690,
      status: 'recibido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      userId: null,
      hasAttachment: false,
      barrio: 'Sur',
    ),
    ReportModel(
      id: '4',
      type: 'sospechoso',
      description: 'Persona merodeando cerca del parque',
      latitude: -2.1200,
      longitude: -79.5650,
      status: 'en_revision',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      userId: null,
      hasAttachment: false,
      barrio: 'Este',
    ),
    ReportModel(
      id: '5',
      type: 'accidente',
      description: 'Motociclista caído en ciclovía',
      latitude: -2.1220,
      longitude: -79.5660,
      status: 'atendido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 48)),
      userId: null,
      hasAttachment: false,
      barrio: 'Oeste',
    ),
    ReportModel(
      id: '6',
      type: 'sospechoso',
      description: 'Vehículo sospechoso rondando zona residencial',
      latitude: -2.1280,
      longitude: -79.5710,
      status: 'recibido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 60)),
      userId: null,
      hasAttachment: false,
      barrio: 'Norte',
    ),
    // Menores (daños viales y otros)
    ReportModel(
      id: '7',
      type: 'daño_vial',
      description: 'Hueco peligroso en calle 3ra y 8va',
      latitude: -2.1280,
      longitude: -79.5710,
      status: 'en_revision',
      timestamp: DateTime.now().subtract(const Duration(minutes: 90)),
      userId: null,
      hasAttachment: false,
      barrio: 'Centro',
    ),
    ReportModel(
      id: '8',
      type: 'otro',
      description: 'Árbol caído obstruyendo la vía',
      latitude: -2.1210,
      longitude: -79.5680,
      status: 'recibido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 120)),
      userId: null,
      hasAttachment: false,
      barrio: 'Sur',
    ),
  ];

  // Mock user reports
  final Map<String, List<ReportModel>> _userReports = {};

  Future<List<ReportModel>> getRecentReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _neighborhoodReports;
  }

  Future<ReportModel> submitReport(
    String type,
    String description,
    double latitude,
    double longitude,
    String userId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final report = ReportModel(
      id: const Uuid().v4(),
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      status: 'recibido',
      timestamp: DateTime.now(),
      userId: userId,
      hasAttachment: false,
      barrio: 'Centro', // Default barrio for user reports
    );

    // Store in user's reports
    if (!_userReports.containsKey(userId)) {
      _userReports[userId] = [];
    }
    _userReports[userId]!.insert(0, report);

    return report;
  }

  Future<List<ReportModel>> getUserHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_userReports.containsKey(userId)) {
      // Generate mock history for new users
      _userReports[userId] = [
        ReportModel(
          id: '${userId}_1',
          type: 'robo',
          description: 'Reporté un asalto en zona residencial',
          latitude: -2.1234,
          longitude: -79.5678,
          status: 'atendido',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          userId: userId,
          hasAttachment: false,
          barrio: 'Centro',
        ),
        ReportModel(
          id: '${userId}_2',
          type: 'sospechoso',
          description: 'Persona desconocida rondando en la noche',
          latitude: -2.1250,
          longitude: -79.5690,
          status: 'en_revision',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          userId: userId,
          hasAttachment: false,
          barrio: 'Centro',
        ),
        ReportModel(
          id: '${userId}_3',
          type: 'accidente',
          description: 'Reporté un accidente vial',
          latitude: -2.1200,
          longitude: -79.5650,
          status: 'recibido',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          userId: userId,
          hasAttachment: false,
          barrio: 'Centro',
        ),
      ];
    }

    return _userReports[userId] ?? [];
  }
}
