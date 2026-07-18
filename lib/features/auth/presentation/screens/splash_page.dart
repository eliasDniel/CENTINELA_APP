import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

/// Réplica visual del splash nativo para transición sin parpadeos.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const _iconAsset = 'assets/icons/splash_icon.png';

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.sizeOf(context).width * 0.22;

    return Scaffold(
      backgroundColor: AppConfig.background,
      body: Center(
        child: Image.asset(
          _iconAsset,
          width: iconSize,
          height: iconSize,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
