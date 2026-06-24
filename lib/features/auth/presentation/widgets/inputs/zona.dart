import 'package:formz/formz.dart';

enum ZonaError { empty }

class Zona extends FormzInput<String, ZonaError> {
  const Zona.pure() : super.pure('');

  const Zona.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == ZonaError.empty) {
      return 'Debe seleccionar una zona';
    }

    return null;
  }

  @override
  ZonaError? validator(String value) {
    if (value.trim().isEmpty) {
      return ZonaError.empty;
    }

    return null;
  }
}
