// register_form.dart
import 'package:centinela_milagro/core/utils/app_snackbar.dart';
import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_colors.dart';
import 'custom_auth_field.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _aliasCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _phoneCtrl;


  @override
  void initState() {
    super.initState();
    ref.read(registerFormProvider.notifier).loadZonas();
    _emailCtrl = TextEditingController();
    _aliasCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _aliasCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailCtrl.clear();
    _aliasCtrl.clear();
    _passwordCtrl.clear();
    _phoneCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final registerForm = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);

    ref.listen(registerFormProvider, (previous, next) {
      if (next.isRegistered && !(previous?.isRegistered ?? false)) {
        _clearFields();
        AppSnackBar.show(
          context,
          message: 'Revisa tu email para verificar tu cuenta',
          type: SnackBarType.success,
        );
      }

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
          enabled: !registerForm.isPosting,
          errorMessage: registerForm.email.errorMessage,
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 16),
        CustomAuthField(
          controller: _aliasCtrl,
          label: 'Alias',
          hint: 'NICKNAME DE BATALLA',
          prefixIcon: Icons.person_outline,
          enabled: !registerForm.isPosting,
          errorMessage: registerForm.alias.errorMessage,
          onChanged: notifier.onAliasChanged,
        ),
        const SizedBox(height: 16),
        _CustomPasswordField(
          controller: _passwordCtrl,
          isPosting: registerForm.isPosting,
          isFormPosted: registerForm.isFormPosted,
          passwordValid: registerForm.password.isValid,
          errorMessage: registerForm.password.errorMessage,
          onChanged: notifier.onPasswordChanged,
        ),
        const SizedBox(height: 16),
        CustomAuthField(
          controller: _phoneCtrl,
          isBottomField: true,
          label: 'Teléfono (opcional)',
          hint: '09XXXXXXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          enabled: !registerForm.isPosting,
          onChanged: notifier.onPhoneChanged,
          // Solo muestra error si tiene contenido
          errorMessage: registerForm.phone.value.isEmpty
              ? null
              : registerForm.phone.errorMessage,
        ),
        const SizedBox(height: 16),
DropdownButtonFormField<ZonaEntity>(
  value: registerForm.zona.value.isNotEmpty
      ? registerForm.zonas.firstWhere(
          (zona) => zona.id == registerForm.zona.value,
          orElse: () => registerForm.zonas.first,
        )
      : null,
  decoration: const InputDecoration(
    labelText: 'Zona / Parroquia',
    prefixIcon: Icon(Icons.map_outlined),
    floatingLabelBehavior: FloatingLabelBehavior.always, // <-- esto
  ),
  hint: const Text('Selecciona una zona'), // <-- opcional pero recomendado
  items: registerForm.zonas.map((zona) {
    return DropdownMenuItem(value: zona, child: Text(zona.nombre));
  }).toList(),
  onChanged: registerForm.isPosting
      ? null
      : (value) {
          if (value != null) notifier.onZonaChanged(value.id);
        },
  validator: (_) =>
      registerForm.isFormPosted && !registerForm.zona.isValid
          ? registerForm.zona.errorMessage
          : null,
),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: registerForm.isPosting ? null : notifier.onSubmit,
            child: registerForm.isPosting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConfig.textPrimary,
                      ),
                    ),
                  )
                : const Text('Crear cuenta'),
          ),
        ),
      ],
    );
  }
}

class _CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isPosting;
  final bool isFormPosted;
  final bool passwordValid;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  const _CustomPasswordField({
    required this.controller,
    required this.isPosting,
    required this.isFormPosted,
    required this.passwordValid,
    required this.errorMessage,
    required this.onChanged,
  });

  @override
  State<_CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<_CustomPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomAuthField(
      controller: widget.controller,
      label: 'Contraseña',
      hint: 'Mínimo 6 caracteres',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscure,
      enabled: !widget.isPosting,
      errorMessage: widget.errorMessage,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
