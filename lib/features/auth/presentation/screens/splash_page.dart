// RF: Splash page - Entry to the app
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 80, color: AppConfig.primary)
                .animate()
                .fade(duration: 1000.ms)
                .scale(duration: 1000.ms),
            const SizedBox(height: 24),
            Text(
              'BarrioSeguro',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            )
                .animate(delay: 300.ms)
                .fade(duration: 800.ms),
            const SizedBox(height: 12),
            Text(
              'Tu barrio, tu seguridad',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
                .animate(delay: 600.ms)
                .fade(duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
