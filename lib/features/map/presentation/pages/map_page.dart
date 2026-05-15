// RF-0306: página del mapa accesible sin autenticación
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_alert_entity.dart';
import '../providers/map_provider.dart';
import '../widgets/alert_detail_sheet.dart';
import '../widgets/alert_marker_widget.dart';
import '../widgets/map_legend_widget.dart';
import '../widgets/radius_badge_widget.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();

  String _subtitle(MapState state) {
    return 'Radio 3km · Actualizado hace ${state.secondsSinceUpdate}s';
  }

  Future<void> _openFiltersSheet(MapState state) async {
    AlertLevel? selectedLevel = state.levelFilter;
    AlertSource? selectedSource = state.sourceFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            Widget filterChip<T>({
              required String label,
              required T? value,
              required T? selectedValue,
              required ValueChanged<T?> onChanged,
            }) {
              final isSelected = value == null ? selectedValue == null : selectedValue == value;
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setStateSheet(() {
                    onChanged(selected ? value : null);
                  });
                },
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF10131A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filtrar alertas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Nivel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertLevel>(label: 'Todos', value: null, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Vigilancia', value: AlertLevel.vigilancia, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Alerta', value: AlertLevel.alerta, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                        filterChip<AlertLevel>(label: 'Emergencia', value: AlertLevel.emergencia, selectedValue: selectedLevel, onChanged: (value) => selectedLevel = value),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Fuente', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterChip<AlertSource>(label: 'Todos', value: null, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                        filterChip<AlertSource>(label: 'Sensores IoT', value: AlertSource.sensor_audio, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                        filterChip<AlertSource>(label: 'Ciudadanos', value: AlertSource.ciudadano, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                        filterChip<AlertSource>(label: 'Hidrológico', value: AlertSource.sensor_hidrico, selectedValue: selectedSource, onChanged: (value) => selectedSource = value),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ref.read(mapProvider.notifier).applyFilters(selectedLevel, selectedSource);
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAlertSheet(MapAlertEntity alert) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AlertDetailSheet(
          alert: alert,
          onCenterMap: () {
            Navigator.pop(context);
            ref.read(mapProvider.notifier).centerOnAlert(alert);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    ref.listen<MapAlertEntity?>(
      mapProvider.select((state) => state.lastIncomingAlert),
      (previous, next) {
        if (next != null && next.id != previous?.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🔔 Nueva alerta en ${next.barrio}')),
          );
        }
      },
    );

    ref.listen<LatLng>(
      mapProvider.select((state) => state.center),
      (previous, next) {
        _mapController.move(next, 14.2);
      },
    );

    if (state.allAlerts.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF10131A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final markers = state.filteredAlerts
        .map(
          (alert) => Marker(
            width: 64,
            height: 64,
            point: alert.position,
            child: AlertMarkerWidget(
              alert: alert,
              onTap: () => _openAlertSheet(alert),
            ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10131A),
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas Activas',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              _subtitle(state),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openFiltersSheet(state),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrar alertas',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.center,
              initialZoom: 14.2,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.barrioseguro.app',
                tileProvider: NetworkTileProvider(),
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const LatLng(-2.1344, -79.5874),
                    radius: 3000,
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.08),
                    borderColor: const Color(0xFF1E90FF),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution('© OpenStreetMap contributors © CartoDB'),
                ],
              ),
            ],
          ),
          const RadiusBadgeWidget(),
          const MapLegendWidget(),
        ],
      ),
    );
  }
}
