// RF-0304, RF-0307: Report card widget with redesigned layout
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/constants/incident_types.dart';
import '../../domain/entities/report_entity.dart';
import '../../../../core/utils/app_colors.dart';

class ReportCardWidget extends ConsumerWidget {
  final ReportEntity report;

  const ReportCardWidget({super.key, required this.report});

  IconData _getIconForType(String type) => incidentTypeIcon(type);

  Color _getColorForType(String type) => incidentTypeColor(type);

  Color _getBarrioColor(String barrio) {
    switch (barrio) {
      case 'Milagro':
        return const Color(0xFF5856D6);
      case 'Chobo':
        return const Color(0xFFFF2D55);
      case 'Mariscal Sucre':
        return AppConfig.warning;
      case 'Roberto Astudillo':
        return AppConfig.success;
      default:
        return AppConfig.textTertiary;
    }
  }

String _formatTime(String createdAt) {
  final time = DateTime.parse(createdAt).toLocal();
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) {
    return 'justo ahora';
  } else if (diff.inMinutes < 60) {
    return 'hace ${diff.inMinutes} min';
  } else if (diff.inHours < 24) {
    return 'hace ${diff.inHours}h';
  } else {
    return 'hace ${diff.inDays}d';
  }
}
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDIENTE':
        return AppConfig.warning;
      case 'EN_PROCESO':
        return AppConfig.primary;
      case 'RESUELTO':
        return AppConfig.success;
      default:
        return AppConfig.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDIENTE':
        return '● Recibido';
      case 'EN_PROCESO':
        return '● En Revisión';
      case 'RESUELTO':
        return '● Atendido';
      default:
        return status;
    }
  }

  String _getTitleForType(String type) => incidentTypeLabel(type);

  void _openDetail(BuildContext context) {
    context.push('/home/2/report/${report.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Card(
    
        child: Container(
          margin: EdgeInsets.all(AppConfig.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Ícono + Tipo + Descripción
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getColorForType(report.tipo).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(report.tipo),
                      color: _getColorForType(report.tipo),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitleForType(report.tipo),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConfig.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.textTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Estado badge en la esquina inferior derecha
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.estado).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusLabel(report.estado),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report.estado),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
