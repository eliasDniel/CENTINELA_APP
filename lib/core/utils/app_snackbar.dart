import 'package:flutter/material.dart';

import 'app_alert.dart';

/// Alias de compatibilidad. Preferir [AppAlert].
@Deprecated('Usa AppAlert en su lugar')
typedef SnackBarType = AppAlertType;

@Deprecated('Usa AppAlert en su lugar')
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    AppAlert.show(context, message: message, type: type);
  }
}
