// RF-0308: detalle de reporte con mapa y estados (datos frescos desde API)
import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:centinela_milagro/core/utils/view_insets.dart';
import 'package:centinela_milagro/core/utils/format_report_datetime.dart';
import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:centinela_milagro/features/map/presentation/widgets/map_floating_controls.dart';
import 'package:centinela_milagro/features/reports/domain/constants/incident_types.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:centinela_milagro/features/reports/presentation/providers/reports_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class ReportDetailPage extends ConsumerStatefulWidget {
  static const routeName = 'report';

  const ReportDetailPage({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  ReportEntity? _report;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final repository = ref.read(reportsRepositoryProvider);
      final report = await repository.getReportById(widget.reportId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } on CustomError catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar el detalle del reporte';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del reporte'),
        backgroundColor: AppConfig.surface.withValues(alpha: 0.95),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadReport,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(context, _report!),
    );
  }

  Widget _buildContent(BuildContext context, ReportEntity report) {
    final userPos = ref.watch(userLocationProvider).position;
    final reportPos = LatLng(report.latitud!, report.longitud!);
    final distance = distanceToUserMeters(userPos, reportPos);

    return RefreshIndicator(
      onRefresh: _loadReport,
      child: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottomViewInset(context)),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ZonaHeader(zona: report.zonaNombre ?? '', type: report.tipo),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _StatusTimeline(status: report.estado),
                const SizedBox(height: 20),
                _ReportMapSection(
                  reportPos: reportPos,
                  userPos: userPos,
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Descripción'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConfig.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppConfig.border),
                  ),
                  child: Text(
                    report.descripcion.isNotEmpty
                        ? report.descripcion
                        : 'Sin descripción',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConfig.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Información'),
                const SizedBox(height: 10),
                _DetailCard(
                  children: [
                    _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Fecha y hora',
                      value: formatReportDateTime(report.createdAt),
                    ),
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'Coordenadas',
                      value:
                          '${report.latitud!.toStringAsFixed(5)}, '
                          '${report.longitud!.toStringAsFixed(5)}',
                    ),
                    _DetailRow(
                      icon: Icons.near_me_outlined,
                      label: 'Distancia de ti',
                      value: formatDistanceMeters(distance),
                    ),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Prioridad',
                      value: '${report.prioridad}/4',
                    ),
                    _DetailRow(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Estado',
                      value: _statusLabel(report.estado),
                      valueColor: _statusColor(report.estado),
                      showDivider: report.evidenceUrls.isEmpty,
                    ),
                  ],
                ),
                if (report.evidenceUrls.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Evidencia'),
                  const SizedBox(height: 10),
                  _EvidenceSection(urls: report.evidenceUrls),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonaHeader extends StatelessWidget {
  const _ZonaHeader({required this.zona, required this.type});

  final String zona;
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
              color: AppConfig.primary.withValues(alpha: 0.15),
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
                  'Zona',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppConfig.textTertiary,
                  ),
                ),
                Text(
                  zona,
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
              color: incidentTypeColor(type).withValues(alpha: 0.15),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
        const _SectionTitle(title: 'Estado del reporte'),
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
                              ? AppConfig.warning.withValues(alpha: 0.2)
                              : AppConfig.success.withValues(alpha: 0.2))
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

class _ReportMapSection extends ConsumerStatefulWidget {
  const _ReportMapSection({
    required this.reportPos,
    required this.userPos,
  });

  final LatLng reportPos;
  final LatLng userPos;

  @override
  ConsumerState<_ReportMapSection> createState() => _ReportMapSectionState();
}

class _ReportMapSectionState extends ConsumerState<_ReportMapSection> {
  final _mapController = MapController();
  bool _mapReady = false;

  static const _defaultZoom = 15.0;

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _mapReady = true);
    _safeMove(widget.reportPos, _defaultZoom);
  }

  void _safeMove(LatLng center, double zoom) {
    if (!_mapReady) return;
    try {
      _mapController.move(center, zoom);
    } catch (_) {
      setState(() => _mapReady = false);
    }
  }

  void _centerOnUser() {
    final userPosition = ref.read(userLocationProvider).position;
    _safeMove(userPosition, _mapController.camera.zoom);
  }

  void _centerOnReport() {
    _safeMove(widget.reportPos, _mapController.camera.zoom);
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    try {
      _mapController.move(
        _mapController.camera.center,
        _mapController.camera.zoom + delta,
      );
    } catch (_) {
      setState(() => _mapReady = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Ubicación'),
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
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.reportPos,
                    initialZoom: _defaultZoom,
                    onMapReady: _onMapReady,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.centinela.milagro',
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.reportPos,
                          width: 40,
                          height: 40,
                          alignment: Alignment.bottomCenter,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppConfig.error,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: widget.userPos,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF42A5F5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
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
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: MapFloatingControls(
                    showCompass: false,
                    compassActive: false,
                    compassAvailable: false,
                    onCompass: () {},
                    onMyLocation: _centerOnUser,
                    onZoomIn: () => _zoomBy(1),
                    onZoomOut: () => _zoomBy(-1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _mapReady ? _centerOnReport : null,
          icon: const Icon(Icons.location_pin, size: 18),
          label: const Text('Centrar en el incidente'),
          style: TextButton.styleFrom(
            foregroundColor: AppConfig.primary,
            padding: EdgeInsets.zero,
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
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConfig.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppConfig.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppConfig.textTertiary),
              ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppConfig.border),
      ],
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.urls});

  final List<String> urls;

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConfig.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConfig.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            urls.length == 1
                ? '1 archivo adjunto'
                : '${urls.length} archivos adjuntos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...urls.map((url) {
            if (_isImageUrl(url)) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _EvidenceChip(url: url),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EvidenceChip(url: url),
            );
          }),
        ],
      ),
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final name = Uri.tryParse(url)?.pathSegments.lastOrNull ?? 'Archivo adjunto';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 18, color: AppConfig.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
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
