// RF-0306: Map page with mock painter and legend
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_provider.dart';
import '../widgets/mock_map_painter.dart';
import '../widgets/map_legend_widget.dart';

class MapPage extends ConsumerWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markersAsync = ref.watch(mapMarkersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Alertas')),
      body: markersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (markers) {
          return Stack(
            children: [
              // Mock map with CustomPaint
              CustomPaint(
                painter: MockMapPainter(markers: markers),
                child: SizedBox.expand(
                  child: GestureDetector(
                    onTapUp: (details) {
                      // Show marker details on tap
                      for (final marker in markers) {
                        final x =
                            ((marker.longitude + 79.57) * 1000) %
                            MediaQuery.of(context).size.width;
                        final y =
                            ((marker.latitude + 2.13) * 1000) %
                            (MediaQuery.of(context).size.height - 100);

                        final distance =
                            (details.globalPosition.dx - x).abs() +
                            (details.globalPosition.dy - y).abs();

                        if (distance < 30) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(marker.label),
                              content: Text(marker.description),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
              // Radio badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: const Text(
                    '📍 Radio: 3km — Vista simulada',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              // Legend
              Positioned(
                bottom: 12,
                right: 12,
                child: MapLegendWidget(),
              ),
            ],
          );
        },
      ),
    );
  }
}
