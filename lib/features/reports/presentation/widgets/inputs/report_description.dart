import 'package:formz/formz.dart';

enum ReportDescriptionError { empty, tooLong }

class ReportDescription extends FormzInput<String, ReportDescriptionError> {
  static const int maxLength = 280;

  const ReportDescription.pure() : super.pure('');

  const ReportDescription.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == ReportDescriptionError.empty) {
      return 'Escribe una descripción del incidente';
    }
    if (displayError == ReportDescriptionError.tooLong) {
      return 'Máximo $maxLength caracteres';
    }
    return null;
  }

  @override
  ReportDescriptionError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return ReportDescriptionError.empty;
    if (trimmed.length > maxLength) return ReportDescriptionError.tooLong;
    return null;
  }
}
