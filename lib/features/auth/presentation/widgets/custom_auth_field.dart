// custom_auth_field.dart
import 'package:flutter/material.dart';

class CustomAuthField extends StatelessWidget {
  final bool isTopField;
  final bool isBottomField;
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomAuthField({
    super.key,
    this.isTopField = false,
    this.isBottomField = false,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Mismo estilo que tu campo de login: borde rojo y más grueso en error.
    final errorBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        errorBorder: errorBorderStyle,
        hintText: hint,
        errorText: errorMessage,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colors.primary)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
