// lib/core/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

enum SnackBarType { error, success, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 3),
          content: Container(
            decoration: BoxDecoration(
              color: config.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: config.borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(config.icon, color: config.iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.outfit(
                      color: AppConfig.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.error:
        return _SnackBarConfig(
          bgColor: AppConfig.error.withOpacity(0.15),
          borderColor: AppConfig.error.withOpacity(0.4),
          iconColor: AppConfig.error,
          icon: Icons.error_outline_rounded,
        );
      case SnackBarType.success:
        return _SnackBarConfig(
          bgColor: const Color(0xFF22C55E).withOpacity(0.15),
          borderColor: const Color(0xFF22C55E).withOpacity(0.4),
          iconColor: const Color(0xFF22C55E),
          icon: Icons.check_circle_outline_rounded,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          bgColor: AppConfig.primary.withOpacity(0.15),
          borderColor: AppConfig.primary.withOpacity(0.4),
          iconColor: AppConfig.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  _SnackBarConfig({
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}
