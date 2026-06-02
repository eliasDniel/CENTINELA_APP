// RF-0308: detalle de reporte con mapa y estados
import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:centinela_milagro/features/reports/domain/constants/incident_types.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class ReportDetailPage extends ConsumerWidget {
  static const routeName = 'report';

  const ReportDetailPage({super.key, required this.report});

  final ReportEntity report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPos = ref.watch(userLocationProvider).position;
    final reportPos = LatLng(report.latitude, report.longitude);
    final distance = distanceToUserMeters(userPos, reportPos);
    final mapCenter = LatLng(
      (reportPos.latitude + userPos.latitude) / 2,
      (reportPos.longitude + userPos.longitude) / 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del reporte'),
      
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _BarrioHeader(barrio: report.barrio, type: report.type),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _StatusTimeline(status: report.status),
                const SizedBox(height: 20),
                _ReportMapSection(
                  center: mapCenter,
                  reportPos: reportPos,
                  userPos: userPos,
                ),

                const SizedBox(height: 20),
                Text(
                  'Descripción',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConfig.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailCard(
                  children: [
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Fecha y hora',
                      value: _formatDateTime(report.timestamp),
                    ),
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'Coordenadas',
                      value:
                          '${report.latitude.toStringAsFixed(5)}, '
                          '${report.longitude.toStringAsFixed(5)}',
                    ),
                    _DetailRow(
                      icon: Icons.near_me_outlined,
                      label: 'Distancia de ti',
                      value: formatDistanceMeters(distance),
                    ),
                    _DetailRow(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Estado',
                      value: _statusLabel(report.status),
                      valueColor: _statusColor(report.status),
                    ),
                    if (report.hasAttachment)
                      const _DetailRow(
                        icon: Icons.attach_file,
                        label: 'Evidencia',
                        value: 'Foto o video adjunto',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarrioHeader extends StatelessWidget {
  const _BarrioHeader({required this.barrio, required this.type});

  final String barrio;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppConfig.surface,
        border: Border(bottom: BorderSide(color: AppConfig.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city, color: AppConfig.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barrio',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppConfig.textTertiary,
                  ),
                ),
                Text(
                  barrio,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: incidentTypeColor(type).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              incidentTypeIcon(type),
              color: incidentTypeColor(type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de reporte',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppConfig.textTertiary,
                  ),
                ),
                Text(
                  incidentTypeLabel(type),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: incidentTypeColor(type),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  int get _stepIndex => switch (status) {
    'recibido' => 0,
    'en_revision' => 1,
    'atendido' => 2,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    const steps = ['Recibido', 'En revisión', 'Atendido'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado del reporte',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepDone = i ~/ 2 < _stepIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: stepDone ? AppConfig.success : AppConfig.border,
                ),
              );
            }
            final step = i ~/ 2;
            final done = step <= _stepIndex;
            final active = step == _stepIndex;
            return Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? (active && status != 'atendido'
                              ? AppConfig.warning.withOpacity(0.2)
                              : AppConfig.success.withOpacity(0.2))
                        : AppConfig.card,
                    border: Border.all(
                      color: done ? AppConfig.success : AppConfig.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.circle,
                    size: done ? 16 : 8,
                    color: done ? AppConfig.success : AppConfig.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 72,
                  child: Text(
                    steps[step],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: done
                          ? AppConfig.textPrimary
                          : AppConfig.textTertiary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _ReportMapSection extends StatelessWidget {
  const _ReportMapSection({
    required this.center,
    required this.reportPos,
    required this.userPos,
  });

  final LatLng center;
  final LatLng reportPos;
  final LatLng userPos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Rojo: incidente · Azul: tu ubicación',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppConfig.textTertiary),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.centinela.milagro',
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: reportPos,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppConfig.error,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: userPos,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConfig.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppConfig.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? AppConfig.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final d = '${dt.day}/${dt.month}/${dt.year}';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$d · $h:$m';
}

String _statusLabel(String status) => switch (status) {
  'recibido' => 'Recibido',
  'en_revision' => 'En revisión',
  'atendido' => 'Atendido',
  _ => status,
};

Color _statusColor(String status) => switch (status) {
  'recibido' => AppConfig.textTertiary,
  'en_revision' => AppConfig.warning,
  'atendido' => AppConfig.success,
  _ => AppConfig.textSecondary,
};
