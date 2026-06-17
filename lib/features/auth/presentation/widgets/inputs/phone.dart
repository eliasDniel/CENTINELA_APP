import 'package:formz/formz.dart';

enum PhoneError { format }

class Phone extends FormzInput<String, PhoneError> {
  // Celular Ecuador: 09XXXXXXXX
  static final RegExp phoneRegExp = RegExp(r'^09\d{8}$');

  const Phone.pure() : super.pure('');

  const Phone.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    switch (displayError) {
      case PhoneError.format:
        return 'Ingrese un número válido (09XXXXXXXX)';
      default:
        return null;
    }
  }

  @override
  PhoneError? validator(String value) {
    final phone = value.trim();

    if (!phoneRegExp.hasMatch(phone)) {
      return PhoneError.format;
    }

    return null;
  }
}
