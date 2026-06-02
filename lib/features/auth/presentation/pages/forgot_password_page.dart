// RF-0705: recuperar contraseña (simulación)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routeName = 'forgot-password';

  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _aliasController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) {
      setState(() => _error = 'Ingresa tu alias');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          const SizedBox(height: 8),
          Icon(Icons.lock_reset, size: 56, color: AppConfig.primary.withOpacity(0.8)),
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
                ? 'Si el alias está registrado, enviamos un enlace simulado '
                    'para restablecer tu contraseña.'
                : 'Ingresa tu alias. Te enviaremos instrucciones para '
                    'crear una nueva contraseña (simulación).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConfig.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 28),
          if (!_sent) ...[
            TextField(
              controller: _aliasController,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Alias',
                hintText: 'Tu pseudónimo registrado',
                errorText: _error,
                prefixIcon: const Icon(Icons.person_outline),
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
                  const Icon(Icons.mark_email_read_outlined,
                      color: AppConfig.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enlace enviado a alias@centinela.sim (demo)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/auth/${ResetPasswordPage.routeName}'),
              icon: const Icon(Icons.vpn_key_outlined),
              label: const Text('Simular abrir enlace'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Volver al inicio de sesión'),
            ),
          ],
        ],
      ),
    );
  }
}
