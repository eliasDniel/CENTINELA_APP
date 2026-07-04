import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/widgets/inputs/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  static const routeName = 'forgot-password';

  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sent = false;
  String _successMessage = '';
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = Email.dirty(_emailController.text.trim());
    if (!email.isValid) {
      setState(() => _error = email.errorMessage);
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .forgotPassword(email.value);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _sent = true;
        _successMessage = result.message;
        _submittedEmail = email.value;
      });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.lock_reset,
            size: 56,
            color: AppConfig.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            _sent ? 'Revisa tu correo' : '¿Olvidaste tu contraseña?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sent
                ? 'Si $_submittedEmail está registrado, recibirás un correo con '
                    'un enlace para abrir la app y crear una nueva contraseña. '
                    'El enlace expira en 1 hora.'
                : 'Ingresa tu correo. Si está registrado, recibirás '
                    'instrucciones para crear una nueva contraseña.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          if (!_sent) ...[
            TextField(
              controller: _emailController,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'tu@correo.com',
                errorText: _error,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar instrucciones'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConfig.success.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppConfig.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _successMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Revisa también la carpeta de spam. Si usas Gmail en el '
              'teléfono, toca el botón del correo para abrir Centinela.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConfig.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/reset-password'),
              icon: const Icon(Icons.vpn_key_outlined),
              label: const Text('Ingresar token manualmente'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reenviar correo'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Volver al inicio de sesión'),
            ),
          ],
        ],
      ),
    );
  }
}
