// RF-0303: adjuntar foto o video al reporte (Android / iOS)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';

enum ReportMediaKind { photo, video }

class ReportMediaAttachment {
  const ReportMediaAttachment({
    required this.file,
    required this.kind,
  });

  final XFile file;
  final ReportMediaKind kind;
}

class ReportMediaPicker extends StatelessWidget {
  const ReportMediaPicker({
    super.key,
    required this.attachment,
    required this.onChanged,
  });

  final ReportMediaAttachment? attachment;
  final ValueChanged<ReportMediaAttachment?> onChanged;

  static final _picker = ImagePicker();

  Future<void> _pick(BuildContext context, {
    required bool isVideo,
    required ImageSource source,
  }) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(
              source: source,
              maxDuration: const Duration(minutes: 2),
            )
          : await _picker.pickImage(
              source: source,
              imageQuality: 85,
              maxWidth: 1920,
            );

      if (file == null || !context.mounted) return;

      onChanged(ReportMediaAttachment(
        file: file,
        kind: isVideo ? ReportMediaKind.video : ReportMediaKind.photo,
      ));
    } catch (e) {
      if (!context.mounted) return;
      AppAlert.error(context, 'No se pudo obtener el archivo: $e');
    }
  }

  void _showSourceSheet(BuildContext context, {required bool isVideo}) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(isVideo ? 'Grabar video' : 'Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, isVideo: isVideo, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, isVideo: isVideo, source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencia (opcional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Adjunta una foto (JPEG, PNG o WebP, máx. 5 MB). '
          'Los videos no son aceptados por el servidor.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConfig.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        if (attachment == null) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSourceSheet(context, isVideo: false),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Foto'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSourceSheet(context, isVideo: true),
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Video'),
                ),
              ),
            ],
          ),
        ] else
          _AttachmentPreview(
            attachment: attachment!,
            onRemove: () => onChanged(null),
            onReplacePhoto: () =>
                _showSourceSheet(context, isVideo: false),
            onReplaceVideo: () =>
                _showSourceSheet(context, isVideo: true),
          ),
      ],
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.attachment,
    required this.onRemove,
    required this.onReplacePhoto,
    required this.onReplaceVideo,
  });

  final ReportMediaAttachment attachment;
  final VoidCallback onRemove;
  final VoidCallback onReplacePhoto;
  final VoidCallback onReplaceVideo;

  @override
  Widget build(BuildContext context) {
    final isPhoto = attachment.kind == ReportMediaKind.photo;
    final path = attachment.file.path;
    final name = attachment.file.name;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: isPhoto
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _videoPlaceholder(name),
                  )
                : _videoPlaceholder(name),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  isPhoto ? Icons.image_outlined : Icons.videocam_outlined,
                  color: AppConfig.primaryLight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: AppConfig.error),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onReplacePhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Cambiar foto'),
                ),
                TextButton.icon(
                  onPressed: onReplaceVideo,
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: const Text('Cambiar video'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoPlaceholder(String name) {
    return Container(
      color: AppConfig.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline,
              size: 48, color: AppConfig.primaryLight),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppConfig.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
