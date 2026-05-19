// RF-0304, RF-0307: Report card widget with redesigned layout
import 'package:flutter/material.dart';
import '../../domain/entities/report_entity.dart';
import '../../../../core/utils/app_colors.dart';

class ReportCardWidget extends StatelessWidget {
  final ReportEntity report;

  const ReportCardWidget({super.key, required this.report});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'robo':
        return Icons.no_backpack_rounded;
      case 'accidente':
        return Icons.car_crash_rounded;
      case 'sospechoso':
        return Icons.person_search_rounded;
      case 'daño_vial':
        return Icons.construction_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'robo':
        return AppConfig.sos;
      case 'accidente':
        return AppConfig.warning;
      case 'sospechoso':
        return const Color(0xFFFFC107);
      case 'daño_vial':
        return AppConfig.primary;
      default:
        return AppConfig.textTertiary;
    }
  }

  Color _getBarrioColor(String barrio) {
    switch (barrio) {
      case 'Norte':
        return const Color(0xFF5856D6);
      case 'Sur':
        return const Color(0xFFFF2D55);
      case 'Centro':
        return AppConfig.warning;
      case 'Este':
        return AppConfig.success;
      case 'Oeste':
        return AppConfig.primary;
      default:
        return AppConfig.textTertiary;
    }
  }

  String _formatTime(DateTime time) {
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
      case 'recibido':
        return AppConfig.textTertiary;
      case 'en_revision':
        return AppConfig.warning;
      case 'atendido':
        return AppConfig.success;
      default:
        return AppConfig.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'recibido':
        return '● Recibido';
      case 'en_revision':
        return '● En Revisión';
      case 'atendido':
        return '● Atendido';
      default:
        return status;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'robo':
        return 'Robo';
      case 'accidente':
        return 'Accidente';
      case 'sospechoso':
        return 'Sospechoso';
      case 'daño_vial':
        return 'Daño vial';
      default:
        return 'Otro';
    }
  }

  void _showDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTitleForType(report.type),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Barrio:', value: report.barrio),
              _DetailRow(
                label: 'Estado:',
                value: _getStatusLabel(report.status),
              ),
              _DetailRow(
                label: 'Hora:',
                value:
                    '${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
              ),
              _DetailRow(
                label: 'Fecha:',
                value:
                    '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}',
              ),
              const SizedBox(height: 16),
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConfig.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(report.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _DetailRow(
                label: 'Ubicación GPS:',
                value:
                    '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailBottomSheet(context),
      child: Card(
    
        child: Container(
          margin: EdgeInsets.all(AppConfig.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Badge barrio + tiempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getBarrioColor(report.barrio).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getBarrioColor(report.barrio),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      report.barrio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getBarrioColor(report.barrio),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(report.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ícono + Tipo + Descripción
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getColorForType(report.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(report.type),
                      color: _getColorForType(report.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitleForType(report.type),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConfig.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.textSecondary,
                          ),
                        ),
                      ],
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
                    color: _getStatusColor(report.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusLabel(report.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report.status),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConfig.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
