// RF-0303: formulario de reporte con estado (patrón register)
import 'dart:io';

import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart' as app_colors;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/constants/incident_types.dart';
import '../providers/report_form_provider.dart';
import 'incident_type_chips.dart';
import 'report_location_map.dart';
import 'report_media_picker.dart';

class ReportForm extends ConsumerStatefulWidget {
  const ReportForm({super.key});

  @override
  ConsumerState<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<ReportForm>
    with SingleTickerProviderStateMixin {
  late TextEditingController _descriptionController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(reportFormProvider.notifier)
          .initPosition(ref.read(userLocationProvider).position);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateStepChange(VoidCallback action) {
    _animationController.reset();
    action();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(reportFormProvider);
    final notifier = ref.read(reportFormProvider.notifier);

    ref.listen(reportFormProvider, (previous, next) {
      if (next.isSubmitted && !(previous?.isSubmitted ?? false)) {
        AppAlert.success(context, 'Reporte enviado correctamente');
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            if (context.mounted) context.go('/home/2');
          },
        );
      }

      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        AppAlert.error(context, next.errorMessage);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    [
                      'Selecciona el tipo',
                      'Agrega detalles',
                      'Confirma tu reporte',
                    ][form.currentStep],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${form.currentStep + 1}/3',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: app_colors.AppConfig.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 24,
                child: Row(
                  children: List.generate(3, (index) {
                    final isActive = index <= form.currentStep;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 2,
                            color: isActive
                                ? app_colors.AppConfig.primary
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 2,
                            height: 10,
                            color: isActive
                                ? app_colors.AppConfig.primary
                                : Colors.grey.shade700,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _animationController,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                if (form.currentStep == 0) _buildStep1(form, notifier),
                if (form.currentStep == 1) _buildStep2(form, notifier),
                if (form.currentStep == 2) _buildStep3(form),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (form.currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: form.isPosting
                        ? null
                        : () => _animateStepChange(notifier.previousStep),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: app_colors.AppConfig.primary),
                    ),
                    child: const Text('Atrás'),
                  ),
                ),
              if (form.currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: form.isPosting
                      ? null
                      : () {
                          if (form.currentStep == 2) {
                            notifier.onSubmit();
                            return;
                          }
                          _animateStepChange(notifier.nextStep);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: app_colors.AppConfig.primary,
                  ),
                  child: form.isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          form.currentStep == 2 ? 'Enviar Reporte' : 'Siguiente',
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(ReportFormState form, ReportFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué tipo de incidente reportas?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona la categoría que mejor describe el evento',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        IncidentTypeChipsWidget(
          onSelected: notifier.onIncidentTypeChanged,
          selectedType: form.incidentType.value.isEmpty
              ? null
              : form.incidentType.value,
        ),
        if (form.isFormPosted && form.incidentType.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            form.incidentType.errorMessage!,
            style: TextStyle(color: app_colors.AppConfig.error),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep2(ReportFormState form, ReportFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuéntanos más detalles',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe qué sucedió, incluye detalles importantes',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: app_colors.AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: app_colors.AppConfig.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.label, size: 16, color: app_colors.AppConfig.primary),
              const SizedBox(width: 8),
              Text(
                incidentTypeLabel(form.incidentType.value),
                style: TextStyle(
                  color: app_colors.AppConfig.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          maxLength: 280,
          maxLines: 5,
          enabled: !form.isPosting,
          decoration: InputDecoration(
            labelText: 'Descripción del incidente',
            hintText:
                'Describe lo que pasó, dónde, cuándo y otros detalles relevantes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: app_colors.AppConfig.primary,
                width: 2,
              ),
            ),
            errorText: form.isFormPosted ? form.description.errorMessage : null,
            counterText: '${_descriptionController.text.length}/280',
          ),
          onChanged: notifier.onDescriptionChanged,
        ),
        const SizedBox(height: 20),
        ReportLocationMap(
          position: form.position,
          onPositionChanged: notifier.onPositionChanged,
        ),
        const SizedBox(height: 24),
        ReportMediaPicker(
          attachment: form.attachment,
          onChanged: notifier.onAttachmentChanged,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep3(ReportFormState form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisa tu reporte',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Asegúrate de que todo sea correcto antes de enviar',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildReviewSection(
                icon: Icons.label,
                title: 'Tipo de incidente',
                value: incidentTypeLabel(form.incidentType.value),
                backgroundColor: Colors.blue.shade900.withOpacity(0.1),
              ),
              Divider(color: Colors.grey.shade700, height: 1),
              _buildReviewSection(
                icon: Icons.description,
                title: 'Descripción',
                value: form.description.value,
                backgroundColor: Colors.green.shade900.withOpacity(0.1),
                isLongText: true,
              ),
              Divider(color: Colors.grey.shade700, height: 1),
              _buildReviewSection(
                icon: Icons.location_on,
                title: 'Ubicación',
                value:
                    '${form.position.latitude.toStringAsFixed(5)}, '
                    '${form.position.longitude.toStringAsFixed(5)}',
                backgroundColor: Colors.purple.shade900.withOpacity(0.1),
              ),
              if (form.attachment != null) ...[
                Divider(color: Colors.grey.shade700, height: 1),
                _buildAttachmentReviewSection(form.attachment!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade700.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.green.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu reporte será revisado por el equipo de seguridad',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAttachmentReviewSection(ReportMediaAttachment attachment) {
    final isPhoto = attachment.kind == ReportMediaKind.photo;

    return Container(
      color: Colors.orange.shade900.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPhoto ? Icons.image_outlined : Icons.videocam_outlined,
                size: 20,
                color: app_colors.AppConfig.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isPhoto ? 'Foto adjunta' : 'Video adjunto',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(attachment.file.path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Text(
              attachment.file.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required IconData icon,
    required String title,
    required String value,
    required Color backgroundColor,
    bool isLongText = false,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: app_colors.AppConfig.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: isLongText ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
