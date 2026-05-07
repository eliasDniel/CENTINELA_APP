// RF-0302: Register form widget
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(String, String, String, String?) onRegister;
  final bool isLoading;

  const RegisterForm({
    Key? key,
    required this.onSubmit,
    required this.onRegister,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late TextEditingController _aliasController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _barrioController;
  bool _obscurePassword = true;
  String? _aliasError;
  String? _passwordError;
  String? _barrioError;
  String _selectedBarrio = 'Norte';
  final List<String> _barrios = ['Norte', 'Sur', 'Centro', 'Este', 'Oeste'];

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _barrioController = TextEditingController();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _barrioController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _aliasError = _aliasController.text.isEmpty ? 'El alias no puede estar vacío' : null;
      _passwordError = _passwordController.text.isEmpty ? 'La contraseña no puede estar vacía' : null;
      _barrioError = _selectedBarrio.isEmpty ? 'El barrio no puede estar vacío' : null;
    });

    if (_aliasError == null && _passwordError == null && _barrioError == null) {
      widget.onRegister(
        _aliasController.text,
        _passwordController.text,
        _selectedBarrio,
        _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
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
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
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
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedBarrio,
          decoration: InputDecoration(
            labelText: 'Barrio',
            errorText: _barrioError,
            errorBorder: _barrioError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  )
                : null,
          ),
          items: _barrios.map((barrio) {
            return DropdownMenuItem(value: barrio, child: Text(barrio));
          }).toList(),
          onChanged: !widget.isLoading ? (value) {
            setState(() => _selectedBarrio = value ?? _selectedBarrio);
          } : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono (opcional)',
            hintText: 'opcional — se cifra en reposo',
          ),
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _handleRegister,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  )
                : const Text('Registrarse'),
          ),
        ),
      ],
    );
  }
}
