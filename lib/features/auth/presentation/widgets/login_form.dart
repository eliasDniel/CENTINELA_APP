import 'package:centinela_milagro/core/utils/app_snackbar.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    ref.listen(loginFormProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty) {
        AppSnackBar.show(
          context,
          message: next.errorMessage,
          type: SnackBarType.error,
        );
      }
    });

    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.onEmailChanged,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'ejemplo@correo.com',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: loginForm.isFormPosted && !loginForm.email.isValid
                ? loginForm
                      .email
                      .errorMessage // ajusta según tu FormzInput
                : null,
            errorBorder: (loginForm.isFormPosted && !loginForm.email.isValid)
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
          ),
          enabled: !loginForm.isPosting,
        ),
        const SizedBox(height: 16),
        _PasswordField(
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

// Widget separado para manejar el toggle de visibilidad sin rebuilds innecesarios
class _PasswordField extends StatefulWidget {
  final bool isPosting;
  final bool isFormPosted;
  final bool passwordValid;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  const _PasswordField({
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
    return TextFormField(
      onChanged: widget.onChanged,
      obscureText: _obscure,
      enabled: !widget.isPosting,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: widget.isFormPosted && !widget.passwordValid
            ? widget.errorMessage
            : null,
        errorBorder: (widget.isFormPosted && !widget.passwordValid)
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              )
            : null,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
