// RF-0305: cola offline — pendientes de envío
import 'package:flutter/material.dart';

import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:centinela_milagro/features/reports/mock_offline_queue.dart';
import 'package:centinela_milagro/features/reports/offline_pending_item.dart';

class OfflineQueuePage extends StatelessWidget {
  static const routeName = 'offline-queue';

  const OfflineQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List<OfflinePendingItem>.from(mockOfflinePendingItems)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(title: const Text('Pendientes offline')),
      body: items.isEmpty
          ? const _EmptyQueue()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConfig.horizontalMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _PendingTile(item: items[index]),
            ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.item});

  final OfflinePendingItem item;

  @override
  Widget build(BuildContext context) {
    final isSos = item.kind == OfflinePendingKind.sos;
    final color = isSos ? AppConfig.error : AppConfig.warning;
    final icon = isSos ? Icons.sos : Icons.report_outlined;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConfig.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 13, color: AppConfig.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        _formatWhen(item.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppConfig.textTertiary,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppConfig.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pendiente',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppConfig.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done_outlined,
                size: 64, color: AppConfig.textTertiary.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              'Nada pendiente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Los SOS y reportes sin conexión aparecerán aquí hasta sincronizarse.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConfig.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatWhen(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return '${dt.day}/${dt.month}/${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
