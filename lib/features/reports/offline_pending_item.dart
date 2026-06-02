// RF-0305: elemento pendiente de sincronización offline

enum OfflinePendingKind { sos, reporte }

class OfflinePendingItem {
  const OfflinePendingItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.timestamp,
  });

  final String id;
  final OfflinePendingKind kind;
  final String title;
  final String detail;
  final DateTime timestamp;
}
