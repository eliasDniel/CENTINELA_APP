import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

enum AppAlertType { error, success, info, warning }

/// Alertas unificadas (snackbars y diálogos) con el tema de la app.
class AppAlert {
  AppAlert._();

  static void show(
    BuildContext context, {
    required String message,
    AppAlertType type = AppAlertType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _configFor(type);
    final messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(
            color: config.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: config.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
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
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: config.iconColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message, {Duration? duration}) {
    show(
      context,
      message: message,
      type: AppAlertType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void error(BuildContext context, String message, {Duration? duration}) {
    show(
      context,
      message: message,
      type: AppAlertType.error,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    show(
      context,
      message: message,
      type: AppAlertType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void warning(BuildContext context, String message, {Duration? duration}) {
    show(
      context,
      message: message,
      type: AppAlertType.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Diálogo de confirmación con estilo del tema.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: AppConfig.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: AppConfig.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  destructive ? AppConfig.error : AppConfig.primary,
              foregroundColor: AppConfig.textPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  static Color _opaqueTint(Color accent, {double strength = 0.32}) {
    return Color.alphaBlend(
      accent.withValues(alpha: strength),
      AppConfig.card,
    );
  }

  static _AlertConfig _configFor(AppAlertType type) {
    switch (type) {
      case AppAlertType.error:
        return _AlertConfig(
          bgColor: _opaqueTint(AppConfig.error),
          borderColor: AppConfig.error.withValues(alpha: 0.65),
          iconColor: AppConfig.error,
          icon: Icons.error_outline_rounded,
        );
      case AppAlertType.success:
        return _AlertConfig(
          bgColor: _opaqueTint(AppConfig.success),
          borderColor: AppConfig.success.withValues(alpha: 0.65),
          iconColor: AppConfig.success,
          icon: Icons.check_circle_outline_rounded,
        );
      case AppAlertType.warning:
        return _AlertConfig(
          bgColor: _opaqueTint(AppConfig.warning),
          borderColor: AppConfig.warning.withValues(alpha: 0.65),
          iconColor: AppConfig.warning,
          icon: Icons.warning_amber_rounded,
        );
      case AppAlertType.info:
        return _AlertConfig(
          bgColor: _opaqueTint(AppConfig.primary),
          borderColor: AppConfig.primary.withValues(alpha: 0.65),
          iconColor: AppConfig.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _AlertConfig {
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  const _AlertConfig({
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}
