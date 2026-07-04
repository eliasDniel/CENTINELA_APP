import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/inputs/inputs.dart';
import '../widgets/report_media_picker.dart';
import 'reports_provider.dart';
import 'reports_repository_provider.dart';

class ReportFormState {
  final int currentStep;
  final bool isPosting;
  final bool isSubmitted;
  final bool isFormPosted;
  final bool isValid;
  final String errorMessage;
  final IncidentType incidentType;
  final ReportDescription description;
  final LatLng position;
  final ReportMediaAttachment? attachment;

  const ReportFormState({
    this.currentStep = 0,
    this.isPosting = false,
    this.isSubmitted = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.errorMessage = '',
    this.incidentType = const IncidentType.pure(),
    this.description = const ReportDescription.pure(),
    this.position = milagroMapCenter,
    this.attachment,
  });

  ReportFormState copyWith({
    int? currentStep,
    bool? isPosting,
    bool? isSubmitted,
    bool? isFormPosted,
    bool? isValid,
    String? errorMessage,
    IncidentType? incidentType,
    ReportDescription? description,
    LatLng? position,
    ReportMediaAttachment? attachment,
    bool clearAttachment = false,
  }) {
    return ReportFormState(
      currentStep: currentStep ?? this.currentStep,
      isPosting: isPosting ?? this.isPosting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      position: position ?? this.position,
      attachment: clearAttachment ? null : attachment ?? this.attachment,
    );
  }
}

class ReportFormNotifier extends StateNotifier<ReportFormState> {
  final Future<String?> Function(Map<String, dynamic> data) submitCallback;
  final Future<String> Function({
    required String filePath,
    String? filename,
  })
  uploadMedia;

  ReportFormNotifier({
    required this.submitCallback,
    required this.uploadMedia,
  }) : super(const ReportFormState());

  void initPosition(LatLng position) {
    state = state.copyWith(position: position);
  }

  void onIncidentTypeChanged(String value) {
    final incidentType = IncidentType.dirty(value);
    state = state.copyWith(
      incidentType: incidentType,
      isValid: Formz.validate([incidentType, state.description]),
    );
  }

  void onDescriptionChanged(String value) {
    final description = ReportDescription.dirty(value);
    state = state.copyWith(
      description: description,
      isValid: Formz.validate([state.incidentType, description]),
    );
  }

  void onPositionChanged(LatLng position) {
    state = state.copyWith(position: position);
  }

  void onAttachmentChanged(ReportMediaAttachment? attachment) {
    if (attachment == null) {
      state = state.copyWith(clearAttachment: true);
      return;
    }
    state = state.copyWith(attachment: attachment);
  }

  void nextStep() {
    if (state.currentStep == 0) {
      final incidentType = IncidentType.dirty(state.incidentType.value);
      if (!Formz.validate([incidentType])) {
        state = state.copyWith(
          isFormPosted: true,
          incidentType: incidentType,
          errorMessage: incidentType.errorMessage ?? '',
        );
        return;
      }
      state = state.copyWith(
        incidentType: incidentType,
        currentStep: 1,
        errorMessage: '',
      );
      return;
    }

    if (state.currentStep == 1) {
      final description = ReportDescription.dirty(state.description.value);
      if (!Formz.validate([description])) {
        state = state.copyWith(
          isFormPosted: true,
          description: description,
          errorMessage: description.errorMessage ?? '',
        );
        return;
      }
      state = state.copyWith(
        description: description,
        currentStep: 2,
        errorMessage: '',
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: '',
      );
    }
  }

  Future<void> onSubmit() async {
    _touchEveryField();
    if (!Formz.validate([state.incidentType, state.description])) return;

    state = state.copyWith(isPosting: true, errorMessage: '');

    try {
      final fotosUrls = <String>[];
      final attachment = state.attachment;

      if (attachment != null) {
        final url = await uploadMedia(
          filePath: attachment.file.path,
          filename: attachment.file.name,
        );
        fotosUrls.add(url);
      }

      final errorMessage = await submitCallback({
        'tipo': state.incidentType.value,
        'descripcion': state.description.value.trim(),
        'latitud': state.position.latitude,
        'longitud': state.position.longitude,
        'fotosUrls': fotosUrls,
      });

      final isSuccess = errorMessage == null;
      state = state.copyWith(
        isPosting: false,
        isSubmitted: isSuccess,
        errorMessage: errorMessage ?? '',
      );
    } on CustomError catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'No se pudo enviar el reporte',
      );
    }
  }

  void _touchEveryField() {
    final incidentType = IncidentType.dirty(state.incidentType.value);
    final description = ReportDescription.dirty(state.description.value);

    state = state.copyWith(
      isFormPosted: true,
      incidentType: incidentType,
      description: description,
      isValid: Formz.validate([incidentType, description]),
    );
  }
}

final reportFormProvider =
    StateNotifierProvider.autoDispose<ReportFormNotifier, ReportFormState>((
      ref,
    ) {
      final repository = ref.read(reportsRepositoryProvider);
      return ReportFormNotifier(
        submitCallback: ref.read(reportsProvider.notifier).submitReport,
        uploadMedia: repository.uploadReportMedia,
      );
    });
