// RF-0309: Profile page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/presentation/providers/reports_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/utils/app_colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
            children: [
              // SECCIÓN: Mi cuenta
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/anonimo.png'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authState.user?.alias ?? 'Usuario',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
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
                        child: SelectableText(
                          authState.user?.uuid ?? 'N/A',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Barrio: $userBarrio',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // SECCIÓN: Mi configuración
              Text(
                'Mi configuración',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Simular modo offline'),
                      subtitle: const Text('Guardar alertas localmente'),
                      value: isOffline,
                      onChanged: (value) {
                        offlineNotifier.toggleOffline(value);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Barrios suscritos'),
                      subtitle: Text(
                        '$userBarrio${barriosSuscribed.isNotEmpty ? ' + ${barriosSuscribed.length}' : ''}',
                      ),
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
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                ...barrios
                                    .where((b) => b != userBarrio)
                                    .map((barrio) {
                                  final isSelected =
                                      barriosSuscribed.contains(barrio);
                                  return CheckboxListTile(
                                    title: Text(barrio),
                                    value: isSelected,
                                    onChanged: (value) {
                                      if (value == true &&
                                          !isSelected &&
                                          barriosSuscribed.length >= 3) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // SECCIÓN: Sesión
              Text(
                'Sesión',
                style: Theme.of(context).textTheme.titleMedium,
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
