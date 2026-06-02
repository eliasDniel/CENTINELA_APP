// RF-0305: datos quemados — cola offline (prototipo)
import 'offline_pending_item.dart';

final mockOfflinePendingItems = <OfflinePendingItem>[
  OfflinePendingItem(
    id: 'off-001',
    kind: OfflinePendingKind.sos,
    title: 'SOS de emergencia',
    detail: 'Ubicación: Av. 4 de Noviembre · Norte',
    timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
  ),
  OfflinePendingItem(
    id: 'off-002',
    kind: OfflinePendingKind.reporte,
    title: 'Reporte — Robo',
    detail: 'Asalto en esquina de Central y 5ta',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
  ),
  OfflinePendingItem(
    id: 'off-003',
    kind: OfflinePendingKind.sos,
    title: 'SOS de emergencia',
    detail: 'Sin conexión al activar alerta · Centro',
    timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
  ),
  OfflinePendingItem(
    id: 'off-004',
    kind: OfflinePendingKind.reporte,
    title: 'Reporte — Sicariato',
    detail: 'Hecho reportado cerca del parque central',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];
