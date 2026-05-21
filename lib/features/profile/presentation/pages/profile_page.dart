// RF-0309: Profile page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/presentation/providers/reports_provider.dart';
import '../providers/profile_provider.dart';
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
    final isOffline = ref.watch(isOfflineProvider);
    final offlineNotifier = ref.read(isOfflineProvider.notifier);
    final barriosSuscribed = ref.watch(barriosSubscribedProvider);
    final barriosNotifier = ref.read(barriosSubscribedProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.user?.isVisitor ?? false) {
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

    final barrios = ['Norte', 'Sur', 'Centro', 'Este', 'Oeste'];
    final userBarrio = authState.user?.barrio ?? 'Centro';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN: Mi cuenta
              CardProfile(authState: authState, userBarrio: userBarrio),
              const SizedBox(height: 24),
              // SECCIÓN: Mi configuración
              Text(
                'Mi configuración',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _CardConfig(isOffline: isOffline, offlineNotifier: offlineNotifier, userBarrio: userBarrio, barriosSuscribed: barriosSuscribed, barrios: barrios, barriosNotifier: barriosNotifier),
              const SizedBox(height: 24),
              // SECCIÓN: Sesión
              Text('Sesión', style: Theme.of(context).textTheme.titleMedium),
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
                              authNotifier.logout();
                              context.go('/auth');
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

class _CardConfig extends StatelessWidget {
  const _CardConfig({
    required this.isOffline,
    required this.offlineNotifier,
    required this.userBarrio,
    required this.barriosSuscribed,
    required this.barrios,
    required this.barriosNotifier,
  });

  final bool isOffline;
  final OfflineNotifier offlineNotifier;
  final String userBarrio;
  final List<String> barriosSuscribed;
  final List<String> barrios;
  final BarriosSubscribedNotifier barriosNotifier;

  @override
  Widget build(BuildContext context) {
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
                title: const Text('Alertas en tiempo real'),
                subtitle: const Text('Recibe notificaciones de nuevas alertas'),
                value: true,
                onChanged: (value) {},
                secondary: const Icon(Icons.notifications, color: AppConfig.success),
              ),
              const Divider(color: Colors.white24),
              SwitchListTile(
                title: const Text('Sonido'),
                subtitle: const Text('Sonidos de notificación'),
                value: true,
                onChanged: (value) {},
                secondary: const Icon(Icons.volume_up, color: AppConfig.warning),
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
              SwitchListTile(
                title: const Text('Simular modo offline'),
                subtitle: const Text('Guardar alertas localmente'),
                value: isOffline,
                onChanged: (value) {
                  offlineNotifier.toggleOffline(value);
                },
                secondary: Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud_done,
                  color: isOffline ? AppConfig.sos : AppConfig.success,
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Barrios suscritos'),
                subtitle: Text(
                  '$userBarrio${barriosSuscribed.isNotEmpty ? ' + ${barriosSuscribed.length}' : ''}',
                ),
                leading: Icon(Icons.location_on, color: AppConfig.primary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Barrios suscritos'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barrio propio no seleccionable
                          CheckboxListTile(
                            title: Text('$userBarrio (propio)'),
                            value: true,
                            onChanged: null,
                          ),
                          const Divider(),
                          Text(
                            'Máximo 3 barrios adicionales',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          ...barrios.where((b) => b != userBarrio).map((
                            barrio,
                          ) {
                            final isSelected = barriosSuscribed.contains(
                              barrio,
                            );
                            return CheckboxListTile(
                              title: Text(barrio),
                              value: isSelected,
                              onChanged: (value) {
                                if (value == true &&
                                    !isSelected &&
                                    barriosSuscribed.length >= 3) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Máximo 3 barrios adicionales',
                                      ),
                                    ),
                                  );
                                } else {
                                  barriosNotifier.toggleBarrio(
                                    barrio,
                                    userBarrio,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Listo'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text('Privacidad'),
                subtitle: const Text('Controla quién ve tus reportes'),
                leading: Icon(Icons.lock, color: AppConfig.primary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
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
    required this.userBarrio,
  });

  final AuthState authState;
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
              backgroundImage: AssetImage(
                'assets/images/anonimo.png',
              ),
            ),
            const SizedBox(height: 16),
            
            // Alias
            Text(
              authState.user?.alias ?? 'Usuario',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            
            // Barrio con icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 16, color: AppConfig.primary),
                const SizedBox(width: 4),
                Text(
                  userBarrio,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'UUID copiado: ${authState.user?.uuid}',
                    ),
                  ),
                );
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
                    style: TextStyle(fontSize: 10, color: AppConfig.textTertiary),
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
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}