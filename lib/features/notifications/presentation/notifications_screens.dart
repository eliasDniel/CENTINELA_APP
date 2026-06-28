// RF-0307: centro de notificaciones
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../blocs/notifications/notifications_bloc.dart';
import '../notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const routeName = 'notifications';

  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  void _loadHistory() {
    final token = ref.read(authProvider).user?.token ?? '';
    context.read<NotificationsBloc>().add(NotificationsLoadHistory(token));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final items = state.notifications;
        final unreadCount = state.unreadCount;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificaciones'),
            actions: [
              IconButton(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: state.isLoadingHistory && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const _EmptyNotifications()
                  : RefreshIndicator(
                      onRefresh: () async => _loadHistory(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: AppConfig.horizontalMargin,
                        ),
                        children: [
                          if (state.historyError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                state.historyError!,
                                style: TextStyle(color: AppConfig.warning),
                              ),
                            ),
                          if (unreadCount > 0) ...[
                            _UnreadBanner(count: unreadCount),
                            const SizedBox(height: 8),
                          ],
                          ...items.map(
                            (n) => _NotificationTile(
                              notification: n,
                              onTap: () => _onTapNotification(context, n),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Future<void> _onTapNotification(
    BuildContext context,
    NotificationModel n,
  ) async {
    final accessToken = ref.read(authProvider).user?.token ?? '';
    if (!n.isRead && accessToken.isNotEmpty) {
      context.read<NotificationsBloc>().add(
            NotificationsMarkAsRead(
              accessToken: accessToken,
              notificationId: n.id,
            ),
          );
    }

    if (!context.mounted) return;
    _showDetail(context, n);
  }

  void _showDetail(BuildContext context, NotificationModel n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppConfig.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConfig.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _NotificationIcon(type: n.type, level: n.level),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    n.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              n.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConfig.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(label: n.barrio, icon: Icons.location_on_outlined),
                if (n.level != null)
                  _Chip(
                    label: _levelLabel(n.level!),
                    icon: Icons.flag_outlined,
                    color: _levelColor(n.level!),
                  ),
                _Chip(
                  label: _formatTimestamp(n.timestamp),
                  icon: Icons.schedule,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (n.type != NotificationType.reporteEstado &&
                n.type != NotificationType.suscripcion &&
                n.type != NotificationType.sistema)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/home/1');
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver en mapa'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBanner extends StatelessWidget {
  const _UnreadBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppConfig.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_outlined,
              color: AppConfig.primaryLight, size: 20),
          const SizedBox(width: 10),
          Text(
            '$count sin leer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConfig.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: n.isRead ? AppConfig.card : AppConfig.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: n.type, level: n.level),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: n.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: AppConfig.primaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: AppConfig.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          n.barrio,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppConfig.textTertiary,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatRelative(n.timestamp),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppConfig.textTertiary,
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
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, this.level});

  final NotificationType type;
  final NotificationLevel? level;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      NotificationType.emergencia => AppConfig.error,
      NotificationType.alertaHidrica => const Color(0xFF42A5F5),
      NotificationType.alertaSeguridad => _levelColor(level),
      NotificationType.reporteEstado => AppConfig.success,
      NotificationType.suscripcion => AppConfig.primary,
      NotificationType.sistema => AppConfig.textTertiary,
    };

    final icon = switch (type) {
      NotificationType.emergencia => Icons.sos,
      NotificationType.alertaHidrica => Icons.water_drop_outlined,
      NotificationType.alertaSeguridad => Icons.sensors,
      NotificationType.reporteEstado => Icons.assignment_turned_in_outlined,
      NotificationType.suscripcion => Icons.notifications_active_outlined,
      NotificationType.sistema => Icons.info_outline,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    this.color,
  });

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppConfig.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConfig.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: c)),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppConfig.textTertiary.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              'Sin notificaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Las alertas de tu barrio y barrios suscritos aparecerán aquí.',
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

Color _levelColor(NotificationLevel? level) {
  return switch (level) {
    NotificationLevel.emergencia => AppConfig.error,
    NotificationLevel.alerta => AppConfig.warning,
    NotificationLevel.vigilancia => AppConfig.primaryLight,
    null => AppConfig.primary,
  };
}

String _levelLabel(NotificationLevel level) {
  return switch (level) {
    NotificationLevel.emergencia => 'Emergencia',
    NotificationLevel.alerta => 'Alerta',
    NotificationLevel.vigilancia => 'Vigilancia',
  };
}

String _formatRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays == 1) return 'Ayer';
  if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
  return '${dt.day}/${dt.month}/${dt.year}';
}

String _formatTimestamp(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day}/${dt.month}/${dt.year} · $h:$m';
}
