import 'package:formz/formz.dart';

enum IncidentTypeError { empty }

class IncidentType extends FormzInput<String, IncidentTypeError> {
  const IncidentType.pure() : super.pure('');

  const IncidentType.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == IncidentTypeError.empty) {
      return 'Selecciona un tipo de incidente';
    }
    return null;
  }

  @override
  IncidentTypeError? validator(String value) {
    if (value.isEmpty) return IncidentTypeError.empty;
    return null;
  }
}
