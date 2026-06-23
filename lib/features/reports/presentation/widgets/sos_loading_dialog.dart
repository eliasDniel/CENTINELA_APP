import 'package:flutter/material.dart';

class SosLoadingDialog extends StatelessWidget {
  const SosLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
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
    );
  }
}
