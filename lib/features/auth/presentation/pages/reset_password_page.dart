// RF-0705: restablecer contraseña (simulación)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  static const routeName = 'reset-password';

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nueva = _newController.text;
    final confirm = _confirmController.text;

    if (nueva.length < 6) {
      setState(() => _error = 'Mínimo 6 caracteres');
      return;
    }
    if (nueva != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: AppConfig.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          const SizedBox(height: 8),
          Text(
            'Crea una contraseña nueva',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simulación del enlace de recuperación. En producción '
            'validaríamos el token del correo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConfig.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _newController,
            obscureText: _obscureNew,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              errorText: _error,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar contraseña'),
          ),
        ],
      ),
    );
  }
}
