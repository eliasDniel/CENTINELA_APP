import 'package:flutter/material.dart';

import '../../../../core/utils/app_alert.dart';

class SosConfirmDialog {
  SosConfirmDialog._();

  static Future<bool?> show(BuildContext context) {
    return AppAlert.confirm(
      context,
      title: 'Confirmar alerta de emergencia',
      message:
          'Se enviará tu ubicación a los contactos y operadores de Centinela Milagro.',
      confirmLabel: 'ENVIAR ALERTA',
      cancelLabel: 'Cancelar',
      destructive: true,
    );
  }
}
