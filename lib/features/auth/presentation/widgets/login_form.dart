// login_form.dart
import 'package:centinela_milagro/core/utils/app_snackbar.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'custom_auth_field.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl    = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(loginFormProvider);
    final notifier  = ref.read(loginFormProvider.notifier);

    ref.listen(loginFormProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        AppSnackBar.show(
          context,
          message: next.errorMessage,
          type: SnackBarType.error,
        );
      }
    });

    return Column(
      children: [
        CustomAuthField(
          controller: _emailCtrl,
          isTopField: true,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: !loginForm.isPosting,
          errorMessage: loginForm.isFormPosted && !loginForm.email.isValid
              ? loginForm.email.errorMessage
              :null,
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 16),
        _PasswordField(
          controller: _passwordCtrl,
          isPosting: loginForm.isPosting,
          isFormPosted: loginForm.isFormPosted,
          passwordValid: loginForm.password.isValid,
          errorMessage: loginForm.password.errorMessage,
          onChanged: notifier.onPasswordChanged,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loginForm.isPosting
                ? null
                : () => context.push('/auth/forgot-password'),
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loginForm.isPosting ? null : notifier.onSubmit,
            child: loginForm.isPosting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Entrar'),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isPosting;
  final bool isFormPosted;
  final bool passwordValid;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.controller,
    required this.isPosting,
    required this.isFormPosted,
    required this.passwordValid,
    required this.errorMessage,
    required this.onChanged,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomAuthField(
      controller: widget.controller,
      isBottomField: true,
      label: 'Contraseña',
      hint: 'Tu contraseña',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscure,
      enabled: !widget.isPosting,
      errorMessage: widget.isFormPosted && !widget.passwordValid
          ? widget.errorMessage
          : null,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}