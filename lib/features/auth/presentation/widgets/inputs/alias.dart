import 'package:formz/formz.dart';

// Define input validation errors
enum AliasError { empty, tooLong }

// Extend FormzInput and provide the input type and error type.
class Alias extends FormzInput<String, AliasError> {
  static const int maxLength = 100;

  // Call super.pure to represent an unmodified form input.
  const Alias.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Alias.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == AliasError.empty) return 'El campo es requerido';
    if (displayError == AliasError.tooLong)
      return 'No puede tener más de 100 caracteres';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  AliasError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return AliasError.empty;
    if (value.length > maxLength) return AliasError.tooLong;
    return null;
  }
}
