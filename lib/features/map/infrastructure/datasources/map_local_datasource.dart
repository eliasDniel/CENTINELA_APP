// RF-0101, RF-0102, RF-0105, RF-0204, RF-0303, RF-0304: mock local datasource del mapa
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/entities/map_alert_entity.dart';

class MapLocalDataSource {
  final _uuid = const Uuid();
  final _random = Random();
  List<MapAlertEntity>? _alerts;

  Future<List<MapAlertEntity>> getActiveAlerts() async {
    await Future.delayed(const Duration(milliseconds: 350));
    _alerts ??= _seedAlerts();
    return List.unmodifiable(_alerts!);
  }

  /// RF-0304 / RF-0305: SOS del ciudadano → nueva alerta en el mapa.
  MapAlertEntity addSosAlert({
    required double lat,
    required double lng,
    required String barrio,
    String? pseudonym,
    DateTime? timestamp,
  }) {
    _alerts ??= _seedAlerts();
    final alert = MapAlertEntity(
      id: 'sos_${_uuid.v4()}',
      lat: lat,
      lng: lng,
      type: AlertType.sos,
      source: AlertSource.ciudadano,
      level: AlertLevel.emergencia,
      barrio: barrio,
      description:
          'SOS de emergencia — ubicación enviada${pseudonym != null ? ' · $pseudonym' : ''}',
      timestamp: timestamp ?? DateTime.now(),
      isActive: true,
      pseudonym: pseudonym,
    );
    _alerts!.insert(0, alert);
    return alert;
  }

  List<MapAlertEntity> _seedAlerts() => [
      MapAlertEntity(
        id: 'a001',
        lat: -2.1289,
        lng: -79.5923,
        type: AlertType.disparo,
        source: AlertSource.sensor_audio,
        level: AlertLevel.emergencia,
        barrio: 'Norte',
        description: 'Nodo N-03 detectó disparo con confianza 0.91',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isActive: true,
        nodeId: 'N-03',
        algorithm: 'YAMNet',
        confidence: 0.91,
      ),
      MapAlertEntity(
        id: 'a002',
        lat: -2.1412,
        lng: -79.5801,
        type: AlertType.grito,
        source: AlertSource.sensor_audio,
        level: AlertLevel.alerta,
        barrio: 'Centro',
        description: 'Nodo C-01 clasificó grito humano — confianza 0.83',
        timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
        isActive: true,
        nodeId: 'C-01',
        algorithm: 'YAMNet',
        confidence: 0.83,
      ),
      MapAlertEntity(
        id: 'a003',
        lat: -2.1378,
        lng: -79.5956,
        type: AlertType.vidrio_roto,
        source: AlertSource.sensor_audio,
        level: AlertLevel.alerta,
        barrio: 'Sur',
        description: 'Nodo S-02 detectó rotura de vidrio — confianza 0.79',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        isActive: true,
        nodeId: 'S-02',
        algorithm: 'YAMNet',
        confidence: 0.79,
      ),
      MapAlertEntity(
        id: 'v001',
        lat: -2.1301,
        lng: -79.5845,
        type: AlertType.alarma_vehiculo,
        source: AlertSource.sensor_video,
        level: AlertLevel.vigilancia,
        barrio: 'Norte',
        description: 'Nodo N-01 detectó vehículo sospechoso detenido — YOLOv8n',
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
        isActive: true,
        nodeId: 'N-01',
        algorithm: 'YOLOv8n',
      ),
      MapAlertEntity(
        id: 'v002',
        lat: -2.1456,
        lng: -79.5912,
        type: AlertType.disparo,
        source: AlertSource.sensor_video,
        level: AlertLevel.emergencia,
        barrio: 'Sur',
        description: 'Alerta compuesta: audio + video coinciden en <3s — RF-0107',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isActive: true,
        nodeId: 'V-02',
        algorithm: 'YOLOv8n',
      ),
      MapAlertEntity(
        id: 'h001',
        lat: -2.1334,
        lng: -79.5778,
        type: AlertType.nivel_hidrico,
        source: AlertSource.sensor_hidrico,
        level: AlertLevel.alerta,
        barrio: 'Este',
        description: 'Sensor JSN-SR04T: nivel río +2.3m sobre umbral Alerta',
        timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
        isActive: true,
        waterLevelDelta: 2.3,
      ),
      MapAlertEntity(
        id: 'h002',
        lat: -2.1398,
        lng: -79.5834,
        type: AlertType.nivel_hidrico,
        source: AlertSource.sensor_hidrico,
        level: AlertLevel.emergencia,
        barrio: 'Oeste',
        description: 'EMERGENCIA HÍDRICA: nivel +4.1m — superó umbral Emergencia',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isActive: true,
        waterLevelDelta: 4.1,
      ),
      MapAlertEntity(
        id: 'c001',
        lat: -2.1267,
        lng: -79.5901,
        type: AlertType.reporte_ciudadano,
        source: AlertSource.ciudadano,
        level: AlertLevel.alerta,
        barrio: 'Norte',
        description: 'Ciudadano reportó: Robo en Av. Principal y Calle 5ta',
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        isActive: true,
        pseudonym: '83af-12cd',
      ),
      MapAlertEntity(
        id: 'c002',
        lat: -2.1423,
        lng: -79.5867,
        type: AlertType.sos,
        source: AlertSource.ciudadano,
        level: AlertLevel.emergencia,
        barrio: 'Centro',
        description: 'SOS activado — GPS: -2.1423, -79.5867 — sin texto',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isActive: true,
        pseudonym: 'b7d1-44e8',
      ),
      MapAlertEntity(
        id: 'c003',
        lat: -2.1312,
        lng: -79.5823,
        type: AlertType.reporte_ciudadano,
        source: AlertSource.ciudadano,
        level: AlertLevel.vigilancia,
        barrio: 'Sur',
        description: 'Ciudadano reportó: Daño vial en intersección Calle 3',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        isActive: true,
        pseudonym: '0fd2-91aa',
      ),
    ];

  MapAlertEntity createIncomingAlert() {
    final now = DateTime.now();
    final templates = [
      MapAlertEntity(
        id: _uuid.v4(),
        lat: -2.1361,
        lng: -79.5888,
        type: AlertType.grito,
        source: AlertSource.sensor_audio,
        level: AlertLevel.alerta,
        barrio: 'Centro',
        description: 'Nodo C-04 clasificó grito humano — confianza 0.81',
        timestamp: now,
        isActive: true,
        nodeId: 'C-04',
        algorithm: 'YAMNet',
        confidence: 0.81,
      ),
      MapAlertEntity(
        id: _uuid.v4(),
        lat: -2.1322,
        lng: -79.5799,
        type: AlertType.nivel_hidrico,
        source: AlertSource.sensor_hidrico,
        level: AlertLevel.emergencia,
        barrio: 'Este',
        description: 'Sensor JSN-SR04T: incremento súbito del nivel del río',
        timestamp: now,
        isActive: true,
        waterLevelDelta: 3.6,
      ),
      MapAlertEntity(
        id: _uuid.v4(),
        lat: -2.1442,
        lng: -79.5894,
        type: AlertType.reporte_ciudadano,
        source: AlertSource.ciudadano,
        level: AlertLevel.alerta,
        barrio: 'Oeste',
        description: 'Reporte ciudadano anónimo: vehículo sospechoso circulando lento',
        timestamp: now,
        isActive: true,
        pseudonym: '9c2e-73d1',
      ),
      MapAlertEntity(
        id: _uuid.v4(),
        lat: -2.1297,
        lng: -79.5936,
        type: AlertType.disparo,
        source: AlertSource.sensor_audio,
        level: AlertLevel.emergencia,
        barrio: 'Norte',
        description: 'Nodo N-08 detectó posible disparo con confianza 0.94',
        timestamp: now,
        isActive: true,
        nodeId: 'N-08',
        algorithm: 'YAMNet',
        confidence: 0.94,
      ),
      MapAlertEntity(
        id: _uuid.v4(),
        lat: -2.1388,
        lng: -79.5851,
        type: AlertType.alarma_vehiculo,
        source: AlertSource.sensor_video,
        level: AlertLevel.vigilancia,
        barrio: 'Sur',
        description: 'Nodo S-05 detectó parada prolongada de vehículo no identificado',
        timestamp: now,
        isActive: true,
        nodeId: 'S-05',
        algorithm: 'YOLOv8n',
      ),
    ];

    return templates[_random.nextInt(templates.length)];
  }
}
