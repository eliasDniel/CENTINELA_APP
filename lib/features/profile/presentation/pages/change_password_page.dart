// RF-0705: cambiar contraseña (usuario logueado)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/inputs/password.dart';
import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  static const routeName = 'change-password';

  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final nueva = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      setState(() => _error = 'Ingresa tu contraseña actual');
      return;
    }

    final passwordError = Password.validateStrongPassword(nueva);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }

    if (nueva != confirm) {
      setState(() => _error = 'Las contraseñas nuevas no coinciden');
      return;
    }

    if (current == nueva) {
      setState(
        () => _error = 'La nueva contraseña debe ser distinta a la actual',
      );
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final message = await ref.read(authProvider.notifier).changePassword(
      currentPassword: current,
      newPassword: nueva,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (message == null) {
      AppAlert.success(
        context,
        'Contraseña cambiada correctamente',
        duration: const Duration(seconds: 2),
      );
      context.pop();
      return;
    }

    setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cambiar contraseña')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Inicia sesión para cambiar tu contraseña',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          Text(
            'Actualiza tu contraseña',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuenta: ${user.email}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppConfig.textSecondary),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _currentController,
            obscureText: _obscureCurrent,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: 'Contraseña actual',
              errorText: _error,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newController,
            obscureText: _obscureNew,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              helperText: 'Mínimo 8 caracteres, mayúscula, minúscula y número',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
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
              labelText: 'Confirmar nueva contraseña',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
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
                : const Text('Cambiar contraseña'),
          ),
        ],
      ),
    );
  }
}
