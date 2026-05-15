// RF-0304, RF-0305, RF-0307: Home page
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reports_provider.dart';
import '../widgets/sos_button_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar(),
            // White card area overlapping the gradient
            BottomEmergence(size: size, isOffline: isOffline),

            CustomCardPrsentation(),
          ],
        ),
      ),
    );
  }
}

class BottomEmergence extends StatelessWidget {
  const BottomEmergence({
    super.key,
    required this.size,
    required this.isOffline,
  });

  final Size size;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(AppConfig.horizontalMargin),
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
                  'Pulsa el botón para enviar una alerta de emergencia a Centinela Milagro.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: (size.height * 0.5) - 10,
              child: Center(
                child: SOSButtonWidget(
                  onPressed: () {
                    if (isOffline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '📴 SOS guardado localmente. Se enviará al reconectar',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConfig.horizontalMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido de nuevo,',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                'El sapo del barrio',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundImage: const AssetImage('assets/images/anonimo.png'),
          ),
        ],
      ),
    );
  }
}

class CustomCardPrsentation extends StatelessWidget {
  const CustomCardPrsentation({super.key});

  @override
  Widget build(BuildContext context) {
    return // Address card
    Card(
      margin: EdgeInsets.all(AppConfig.horizontalMargin),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppConfig.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: const AssetImage('assets/images/anonimo.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tu ubicación actual'),
                  SizedBox(height: 6),
                  Text(
                    '151-171 Montclair Ave Newark, NJ 07104, USA',
                    style: TextStyle(color: Colors.white),
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
