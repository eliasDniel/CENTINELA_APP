import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/widgets/inputs/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  static const routeName = 'reset-password';

  final String? resetToken;

  const ResetPasswordPage({super.key, this.resetToken});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _tokenController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final token = widget.resetToken;
    if (token != null && token.isNotEmpty) {
      _tokenController.text = token;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final nueva = _newController.text;
    final confirm = _confirmController.text;

    if (token.isEmpty) {
      setState(() => _error = 'Ingresa el token de recuperación');
      return;
    }

    final passwordError = Password.validateStrongPassword(nueva);
    if (passwordError != null) {
      setState(() => _error = passwordError);
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

    try {
      final message = await ref.read(authRepositoryProvider).resetPassword(
        token: token,
        newPassword: nueva,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      AppAlert.success(context, message);
      context.go('/login');
    } on CustomError catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrefilledToken =
        widget.resetToken != null && widget.resetToken!.isNotEmpty;

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
            hasPrefilledToken
                ? 'El token del enlace ya fue cargado. Define tu nueva contraseña.'
                : 'Pega el token que recibiste por correo (válido por 1 hora).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          if (!hasPrefilledToken) ...[
            TextField(
              controller: _tokenController,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Token de recuperación',
                hintText: 'Pega el token del correo',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _newController,
            obscureText: _obscureNew,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              helperText: 'Mínimo 8 caracteres, mayúscula, minúscula y número',
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => context.go('/login'),
            child: const Text('Volver al inicio de sesión'),
          ),
        ],
      ),
    );
  }
}
