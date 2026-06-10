// RF-0301: Login form widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(String, String) onLogin;
  final bool isLoading;

  const LoginForm({
    Key? key,
    required this.onSubmit,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _aliasController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  String? _aliasError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _aliasError = _aliasController.text.isEmpty ? 'El alias no puede estar vacío' : null;
      _passwordError = _passwordController.text.isEmpty ? 'La contraseña no puede estar vacía' : null;
    });

    if (_aliasError == null && _passwordError == null) {
      widget.onLogin(_aliasController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: _aliasController,
            decoration: InputDecoration(
              labelText: 'Alias',
              hintText: 'Tu pseudónimo',
              errorText: _aliasError,
              errorBorder: _aliasError != null
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppConfig.error, width: 2),
                    )
                  : null,
            ),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Tu contraseña',
              errorText: _passwordError,
              errorBorder: _passwordError != null
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppConfig.error, width: 2),
                    )
                  : null,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            enabled: !widget.isLoading,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () => context.push('/auth/forgot-password'),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleLogin,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConfig.textPrimary),
                      ),
                    )
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}
