import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/notifications_screens.dart';

class HomeHeaderWidget extends ConsumerWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isVisitor = user == null;
    final greeting = isVisitor ? 'Hola,' : 'Bienvenido de nuevo,';
    final name = user == null ? 'visitante' : (user.alias);
    final subtitle = isVisitor
        ? 'Explora el mapa de alertas en un radio de 3 km sin crear cuenta. '
              'Inicia sesión para reportar incidentes y recibir avisos de tu barrio.'
        : 'Puedes enviar SOS o revisar alertas en el mapa.';

    return Container(
      margin: const EdgeInsets.all(AppConfig.horizontalMargin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    height: 1.35,
                  ),
                ),
                if (isVisitor) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Iniciar sesión'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  context.go('/home/0/${NotificationsScreen.routeName}');
                },
                icon: const Icon(Icons.notification_important_outlined, size: 24),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConfig.error,
                  ),
                  child: Text(
                    '1',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
