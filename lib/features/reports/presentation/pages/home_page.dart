// RF-0304, RF-0305, RF-0307: Home page
import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:centinela_milagro/features/notifications/presentation/notifications_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/sos_provider.dart';
import '../widgets/sos_button_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            _HomeSosSection(
              size: size,
              onEmergencySent: () => _handleSosSent(context, ref),
            ),
            const _HomeLocationCard(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isVisitor = user?.isVisitor ?? false;

    final greeting = isVisitor ? 'Hola,' : 'Bienvenido de nuevo,';
    final name = isVisitor ? 'visitante' : (user?.alias ?? 'ciudadano');
    final subtitle = isVisitor
        ? 'Explora el mapa de alertas en un radio de 3 km sin crear cuenta. '
              'Inicia sesión para reportar incidentes y recibir avisos de tu barrio.'
        : 'Estás en el barrio ${user?.barrio ?? '—'}. '
              'Puedes enviar SOS o revisar alertas en el mapa.';

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
                    onPressed: () => context.go('/auth'),
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
              IconButton(onPressed: () {
                context.go('/home/0/${NotificationsScreen.routeName}');
              }, icon: Icon(Icons.notification_important_outlined, size: 24)),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
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

class _HomeSosSection extends StatelessWidget {
  const _HomeSosSection({
    required this.size,
    required this.onEmergencySent,
  });

  final Size size;
  final Future<void> Function() onEmergencySent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(AppConfig.horizontalMargin),
            child: Column(
              children: [
                Text(
                  '¿Necesitas ayuda ahora?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pulsa el botón para enviar una alerta de emergencia con tu ubicación.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(
            height: (size.height * 0.45).clamp(180, 320),
            child: Center(
              child: SOSButtonWidget(onEmergencySent: onEmergencySent),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _handleSosSent(
  BuildContext context,
  WidgetRef ref,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Enviando ubicación y alerta...'),
          ],
        ),
      ),
    ),
  );

  try {
    await sendSosAlert(ref);
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar el SOS: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppConfig.error,
        ),
      );
    }
    return;
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return;

  const message = 'Alerta SOS enviada. Centinela Milagro fue notificado.';

  final onMapTab = isMapTabActive(context);
  if (onMapTab) {
    focusSosOnMapIfReady(ref);
  }

  _showTimedSosSnackBar(
    context: context,
    ref: ref,
    message: message,
    showMapAction: !onMapTab,
  );
}

const _sosSnackDuration = Duration(seconds: 2);

void _showTimedSosSnackBar({
  required BuildContext context,
  required WidgetRef ref,
  required String message,
  required bool showMapAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: _sosSnackDuration,
      backgroundColor: AppConfig.success,
      action: showMapAction
          ? SnackBarAction(
              label: 'Ver mapa',
              textColor: Colors.white,
              onPressed: () {
                messenger.hideCurrentSnackBar();
                openMapForSos(context, ref);
              },
            )
          : null,
    ),
  );

  Future.delayed(_sosSnackDuration, controller.close);
}

class _HomeLocationCard extends ConsumerWidget {
  const _HomeLocationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isVisitor = user?.isVisitor ?? false;
    final location = ref.watch(userLocationProvider);

    return Card(
      margin: EdgeInsets.all(AppConfig.horizontalMargin),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppConfig.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/home/1'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF42A5F5),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVisitor ? 'Tu ubicación (aprox.)' : 'Tu ubicación',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.shortAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConfig.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isVisitor
                          ? 'Toca para ver alertas cerca de ti en el mapa'
                          : 'Barrio ${user?.barrio ?? '—'} · Ver distancia a incidentes en el mapa',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppConfig.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
