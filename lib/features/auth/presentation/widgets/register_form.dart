// RF-0302: Register form widget
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../subscriptions/domain/constants/zonas_administrativas.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(String, String, String, String, String?) onRegister;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late TextEditingController _aliasController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  bool _obscurePassword = true;
  String? _aliasError;
  String? _passwordError;
  String? _zonaError;
  String? _barrioError;
  String _selectedZona = kZonasAdministrativas.first;
  String? _selectedBarrio;

  List<String> get _barriosDeZonaSeleccionada =>
      barriosDeZona(_selectedZona);

  bool get _requiereBarrio => zonaTieneBarrios(_selectedZona);

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedBarrio = _barriosDeZonaSeleccionada.isNotEmpty
        ? _barriosDeZonaSeleccionada.first
        : null;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onZonaChanged(String? zona) {
    if (zona == null) return;
    setState(() {
      _selectedZona = zona;
      final barrios = barriosDeZona(zona);
      _selectedBarrio = barrios.isNotEmpty ? barrios.first : null;
      _zonaError = null;
      _barrioError = null;
    });
  }

  void _handleRegister() {
    setState(() {
      _aliasError =
          _aliasController.text.isEmpty ? 'El alias no puede estar vacío' : null;
      _passwordError = _passwordController.text.isEmpty
          ? 'La contraseña no puede estar vacía'
          : null;
      _zonaError =
          _selectedZona.isEmpty ? 'La zona no puede estar vacía' : null;
      _barrioError = _requiereBarrio &&
              (_selectedBarrio == null || _selectedBarrio!.isEmpty)
          ? 'Debes seleccionar un barrio'
          : null;
    });

    if (_aliasError == null &&
        _passwordError == null &&
        _zonaError == null &&
        _barrioError == null) {
      widget.onRegister(
        _aliasController.text,
        _passwordController.text,
        _selectedZona,
        _selectedBarrio ?? '',
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
                    borderSide:
                        const BorderSide(color: AppConfig.error, width: 2),
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
                    borderSide:
                        const BorderSide(color: AppConfig.error, width: 2),
                  )
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedZona,
          decoration: InputDecoration(
            labelText: 'Zona administrativa',
            errorText: _zonaError,
            errorBorder: _zonaError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppConfig.error, width: 2),
                  )
                : null,
          ),
          items: kZonasAdministrativas.map((zona) {
            return DropdownMenuItem(value: zona, child: Text(zona));
          }).toList(),
          onChanged: !widget.isLoading ? _onZonaChanged : null,
        ),
        if (_requiereBarrio) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedBarrio,
            decoration: InputDecoration(
              labelText: 'Barrio',
              errorText: _barrioError,
              errorBorder: _barrioError != null
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppConfig.error, width: 2),
                    )
                  : null,
            ),
            items: _barriosDeZonaSeleccionada.map((barrio) {
              return DropdownMenuItem(value: barrio, child: Text(barrio));
            }).toList(),
            onChanged: !widget.isLoading
                ? (value) {
                    setState(() {
                      _selectedBarrio = value;
                      _barrioError = null;
                    });
                  }
                : null,
          ),
        ] else ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConfig.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppConfig.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta zona no tiene barrios específicos. '
                    'Las alertas se mostrarán a nivel de toda la zona.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConfig.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono (opcional)',
            hintText: 'opcional — se cifra en reposo',
          ),
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 12),
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppConfig.textPrimary),
                    ),
                  )
                : const Text('Registrarse'),
          ),
        ),
      ],
    );
  }
}
