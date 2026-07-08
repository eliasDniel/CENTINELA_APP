import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscriptions/domain/barrio_membership.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../../domain/utils/map_marker_cluster.dart';
import '../../../../core/location/user_heading_provider.dart';
import '../../../../core/location/user_location_provider.dart';
import '../providers/map_provider.dart';
import 'alert_marker_widget.dart';
import 'map_compact_markers.dart';
import 'user_location_marker.dart';

/// Fondo del lienzo del mapa; debe coincidir con el tema oscuro de Carto.
const kMapCanvasColor = Color(0xFF10131A);

class MapTilesLayer extends StatelessWidget {
  const MapTilesLayer({
    super.key,
    required this.tileProvider,
  });

  final TileProvider tileProvider;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
      userAgentPackageName: 'com.barrioseguro.app',
      retinaMode: RetinaMode.isHighDensity(context),
      tileProvider: tileProvider,
      panBuffer: 2,
      keepBuffer: 3,
      tileDisplay: const TileDisplay.instantaneous(),
      tileBuilder: (context, tileWidget, tile) => ColoredBox(
        color: kMapCanvasColor,
        child: tileWidget,
      ),
    );
  }
}

class MapZonePolygonsLayer extends ConsumerWidget {
  const MapZonePolygonsLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polygons = ref.watch(mapZonePolygonsProvider);
    if (polygons.isEmpty) return const SizedBox.shrink();
    return PolygonLayer(polygons: polygons);
  }
}

class MapProximityCircleLayer extends ConsumerWidget {
  const MapProximityCircleLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCircle = ref.watch(mapShowProximityCircleProvider);
    if (!showCircle) return const SizedBox.shrink();

    final radiusMeters = ref.watch(
      mapProvider.select((s) => s.proximityRadiusMeters),
    );
    if (radiusMeters == null) return const SizedBox.shrink();

    final center = ref.watch(userLocationProvider.select((s) => s.position));

    return CircleLayer(
      circles: [
        CircleMarker(
          point: center,
          radius: radiusMeters.toDouble(),
          useRadiusInMeter: true,
          color: Colors.blue.withValues(alpha: 0.08),
          borderColor: const Color(0xFF1E90FF),
          borderStrokeWidth: 1.5,
        ),
      ],
    );
  }
}

class MapAlertMarkersLayer extends ConsumerStatefulWidget {
  const MapAlertMarkersLayer({
    super.key,
    required this.mapController,
    required this.onAlertTap,
  });

  final MapController mapController;
  final void Function(AlertEntity alert, BarrioMapCategory category) onAlertTap;

  @override
  ConsumerState<MapAlertMarkersLayer> createState() =>
      _MapAlertMarkersLayerState();
}

class _MapAlertMarkersLayerState extends ConsumerState<MapAlertMarkersLayer> {
  StreamSubscription<MapEvent>? _mapEventsSub;
  double _zoom = 14.2;

  @override
  void initState() {
    super.initState();
    _zoom = widget.mapController.camera.zoom;
    _mapEventsSub = widget.mapController.mapEventStream.listen(_onMapEvent);
  }

  @override
  void didUpdateWidget(covariant MapAlertMarkersLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _mapEventsSub?.cancel();
      _zoom = widget.mapController.camera.zoom;
      _mapEventsSub = widget.mapController.mapEventStream.listen(_onMapEvent);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is! MapEventMove && event is! MapEventMoveEnd) return;
    final nextZoom = widget.mapController.camera.zoom;
    if ((nextZoom - _zoom).abs() < 0.2) return;
    setState(() => _zoom = nextZoom);
  }

  @override
  void dispose() {
    _mapEventsSub?.cancel();
    super.dispose();
  }

  void _zoomIntoCluster(MapMarkerCluster cluster) {
    final targetZoom = (_zoom + 1.8).clamp(10.0, 17.5);
    widget.mapController.move(cluster.center, targetZoom);
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(mapProvider.select((s) => s.filteredAlerts));
    final positions = ref.watch(mapProvider.select((s) => s.positions));
    final userZonas = ref.watch(mapProvider.select((s) => s.userZonas));

    if (alerts.isEmpty) return const SizedBox.shrink();

    final useCompact = shouldUseCompactMarkers(
      zoom: _zoom,
      alertCount: alerts.length,
    );
    final clusters = clusterMapAlerts(
      alerts: alerts,
      positions: positions,
      zoom: _zoom,
    );

    final markers = <Marker>[];
    for (final cluster in clusters) {
      if (cluster.isCluster) {
        final size = cluster.alerts.length >= 100
            ? 46.0
            : cluster.alerts.length >= 10
                ? 40.0
                : 34.0;
        markers.add(
          Marker(
            point: cluster.center,
            width: size,
            height: size,
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: MapClusterBubble(
                count: cluster.alerts.length,
                level: cluster.dominantLevel,
                onTap: () => _zoomIntoCluster(cluster),
              ),
            ),
          ),
        );
        continue;
      }

      final alert = cluster.alerts.first;
      final position = positions[alert.id] ?? cluster.center;
      final category = zonaCategoryForAlert(alert, userZonas);

      if (useCompact) {
        markers.add(
          Marker(
            point: position,
            width: 22,
            height: 22,
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: CompactAlertDot(
                alert: alert,
                onTap: () => widget.onAlertTap(alert, category),
              ),
            ),
          ),
        );
        continue;
      }

      markers.add(
        Marker(
          width: kAlertMarkerWidth,
          height: kAlertMarkerHeight,
          alignment: Marker.computePixelAlignment(
            width: kAlertMarkerWidth,
            height: kAlertMarkerHeight,
            left: kAlertPinTipLeft,
            top: kAlertPinTipTop,
          ),
          point: position,
          child: RepaintBoundary(
            child: AlertMarkerWidget(
              alert: alert,
              barrioCategory: category,
              onTap: () => widget.onAlertTap(alert, category),
            ),
          ),
        ),
      );
    }

    if (markers.isEmpty) return const SizedBox.shrink();
    return MarkerLayer(markers: markers);
  }
}

class MapUserLocationLayer extends ConsumerWidget {
  const MapUserLocationLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(userLocationProvider.select((s) => s.position));
    final heading = ref.watch(userHeadingProvider);
    final compassFollow = ref.watch(compassFollowModeProvider);

    return MarkerLayer(
      markers: [
        Marker(
          point: position,
          width: heading.isAvailable ? 72 : 28,
          height: heading.isAvailable ? 72 : 28,
          alignment: Alignment.center,
          child: RepaintBoundary(
            child: UserLocationMarker(
              headingDegrees: heading.headingDegrees,
              beamPointsUpOnScreen: compassFollow && heading.isAvailable,
              showBeam: heading.isAvailable,
            ),
          ),
        ),
      ],
    );
  }
}

class MapFlutterMapView extends ConsumerWidget {
  const MapFlutterMapView({
    super.key,
    required this.mapController,
    required this.tileProvider,
    required this.onMapReady,
    required this.onAlertTap,
    this.initialZoom = 14.2,
  });

  final MapController mapController;
  final TileProvider tileProvider;
  final VoidCallback onMapReady;
  final void Function(AlertEntity alert, BarrioMapCategory category) onAlertTap;
  final double initialZoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialCenter = ref.read(userLocationProvider).position;
    final heading = ref.watch(userHeadingProvider);
    final compassFollow = ref.watch(compassFollowModeProvider);

    return RepaintBoundary(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          backgroundColor: kMapCanvasColor,
          onMapReady: onMapReady,
          interactionOptions: InteractionOptions(
            flags: compassFollow && heading.isAvailable
                ? InteractiveFlag.all & ~InteractiveFlag.rotate
                : InteractiveFlag.all,
          ),
        ),
        children: [
          MapTilesLayer(tileProvider: tileProvider),
          const MapZonePolygonsLayer(),
          const MapProximityCircleLayer(),
          MapAlertMarkersLayer(
            mapController: mapController,
            onAlertTap: onAlertTap,
          ),
          const MapUserLocationLayer(),
        ],
      ),
    );
  }
}

BarrioMapCategory zonaCategoryForAlert(
  AlertEntity alert,
  List<UserZonaEntity> userZonas,
) {
  if (userZonas.isEmpty) return BarrioMapCategory.other;

  final alertZonaId = alert.zonaId ?? alert.zona?.id;
  UserZonaEntity? match;
  if (alertZonaId != null && alertZonaId.isNotEmpty) {
    for (final zone in userZonas) {
      if (zone.zonaId == alertZonaId) {
        match = zone;
        break;
      }
    }
  }
  match ??= userZonas
      .where((zone) => zone.zona.nombre == alert.zonaNombre)
      .firstOrNull;

  if (match == null) return BarrioMapCategory.other;
  if (match.isPrincipal) return BarrioMapCategory.home;
  return BarrioMapCategory.subscribed;
}
