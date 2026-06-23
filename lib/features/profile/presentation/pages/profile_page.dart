// RF-0309: Profile page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/presentation/pages/offline_queue_page.dart';
import '../pages/privacy_page.dart';
import '../pages/change_password_page.dart';
import '../pages/change_location_page.dart';
import '../../../subscriptions/presentation/pages/subscriptions_hub_page.dart';
import '../../../notifications/presentation/notifications_screens.dart';
import '../../../notifications/presentation/providers/notification_settings_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final barriosSuscribed = ref.watch(barriosSubscribedProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Comentado: isVisitor pendiente en UserEntity
    // if (authState.user?.isVisitor ?? false) {
    if (authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Inicia sesión para ver tu perfil',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    // final userZona = authState.user?.zona ?? 'Milagro';
    // final userBarrio = authState.user?.barrio ?? '';
    final userZona = 'Milagro';
    final userBarrio = '';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN: Mi cuenta
              CardProfile(
                authState: authState,
                userZona: userZona,
                userBarrio: userBarrio,
              ),
              const SizedBox(height: 24),
              // SECCIÓN: Mi configuración
              Text(
                'Mi configuración',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _CardConfig(
                userZona: userZona,
                userBarrio: userBarrio,
                barriosSuscribed: barriosSuscribed,
              ),
              const SizedBox(height: 24),
              // SECCIÓN: Sesión
              Text('Sesión', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Cambiar contraseña'),
                  subtitle: const Text('Actualiza tu clave de acceso'),
                  leading: const Icon(
                    Icons.vpn_key_outlined,
                    color: AppConfig.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/home/3/${ChangePasswordPage.routeName}'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Cerrar sesión'),
                  leading: const Icon(Icons.logout, color: AppConfig.error),
                  textColor: AppConfig.error,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Cerrar sesión?'),
                        content: const Text(
                          'Se perderá el acceso a tu historial de reportes.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.error,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              authNotifier.logoutUser();
                          
                            },
                            child: const Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardConfig extends ConsumerWidget {
  const _CardConfig({
    required this.userZona,
    required this.userBarrio,
    required this.barriosSuscribed,
  });

  final String userZona;
  final String userBarrio;
  final List<String> barriosSuscribed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsOn = ref.watch(notificationsEnabledProvider);
    final notificationsNotifier = ref.read(
      notificationsEnabledProvider.notifier,
    );

    return Column(
      children: [
        // Sección: Notificaciones y Sincronización
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: AppConfig.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Notificaciones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24),
              SwitchListTile(
                title: const Text('Recibir notificaciones'),
                subtitle: Text(
                  notificationsOn
                      ? 'Alertas de tu barrio y barrios que sigues'
                      : 'No recibirás alertas push',
                ),
                value: notificationsOn,
                onChanged: notificationsNotifier.setEnabled,
                secondary: Icon(
                  notificationsOn
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                  color: notificationsOn
                      ? AppConfig.success
                      : AppConfig.textTertiary,
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Bandeja de notificaciones'),
                subtitle: const Text('Alertas recibidas'),
                leading: const Icon(
                  Icons.inbox_outlined,
                  color: AppConfig.primary,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/home/3/${NotificationsScreen.routeName}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Sección: Datos y Sincronización
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.cloud_sync, color: AppConfig.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Datos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Pendientes offline'),
                subtitle: const Text('SOS y reportes sin enviar'),
                leading: const Icon(
                  Icons.cloud_off_outlined,
                  color: AppConfig.warning,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/home/3/${OfflineQueuePage.routeName}'),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Cambiar zona y barrio'),
                subtitle: Text(
                  userBarrio.isNotEmpty ? '$userZona · $userBarrio' : userZona,
                ),
                leading: Icon(
                  Icons.edit_location_alt,
                  color: AppConfig.primary,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/home/3/${ChangeLocationPage.routeName}'),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Mis barrios'),
                subtitle: Text(
                  barriosSuscribed.isEmpty
                      ? (userBarrio.isNotEmpty
                            ? '$userBarrio · hasta 3 barrios más'
                            : 'Zona completa · sin barrios específicos')
                      : '$userBarrio + ${barriosSuscribed.join(', ')}',
                ),
                leading: Icon(Icons.location_on, color: AppConfig.primary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/home/3/${SubscriptionsHubPage.routeName}'),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Privacidad'),
                subtitle: const Text('Datos personales y eliminar cuenta'),
                leading: Icon(Icons.lock, color: AppConfig.primary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/home/3/${PrivacyPage.routeName}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardProfile extends StatelessWidget {
  const CardProfile({
    super.key,
    required this.authState,
    required this.userZona,
    required this.userBarrio,
  });

  final AuthState authState;
  final String userZona;
  final String userBarrio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/anonimo.png'),
            ),
            const SizedBox(height: 16),

            // Nombre
            Text(
              // authState.user?.nombre ?? 'Usuario',
            authState.user?.email.split('@').first ?? 'Usuario',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),

            // Barrio con icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppConfig.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  userBarrio.isNotEmpty ? '$userZona · $userBarrio' : userZona,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConfig.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(color: AppConfig.border),
            const SizedBox(height: 12),

            // Estadísticas rápidas (3 columnas)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.report_outlined,
                  label: 'Reportes',
                  value: '12',
                ),
                _StatItem(
                  icon: Icons.thumb_up_outlined,
                  label: 'Útiles',
                  value: '8',
                ),
                _StatItem(
                  icon: Icons.star_outline,
                  label: 'Puntos',
                  value: '240',
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: AppConfig.border),
            const SizedBox(height: 12),

            // UUID copiable
            GestureDetector(
              onTap: () {
                AppAlert.info(context, 'UUID copiado: ${authState.user?.uuid}');
              },
              child: Column(
                children: [
                  Text(
                    'Pseudónimo único',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    authState.user?.uuid ?? 'N/A',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.primary,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toca para copiar',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppConfig.textTertiary,
                    ),
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

// Widget helper para los stats
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppConfig.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
