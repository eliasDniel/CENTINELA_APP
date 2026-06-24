import 'package:flutter/material.dart';

/// Controles flotantes del mapa al estilo Google Maps.
class MapFloatingControls extends StatelessWidget {
  const MapFloatingControls({
    super.key,
    required this.compassActive,
    required this.compassAvailable,
    this.showCompass = true,
    required this.onCompass,
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final bool compassActive;
  final bool compassAvailable;
  final bool showCompass;
  final VoidCallback onCompass;
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  static const _googleBlue = Color(0xFF1A73E8);
  static const _dividerColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCompass) ...[
            _ControlButton(
              icon: Icons.explore_rounded,
              tooltip: 'Modo brújula',
              onPressed: compassAvailable ? onCompass : null,
              iconColor: compassActive && compassAvailable
                  ? _googleBlue
                  : compassAvailable
                  ? const Color(0xFF5F6368)
                  : const Color(0xFFBDBDBD),
              backgroundColor: compassActive && compassAvailable
                  ? _googleBlue.withValues(alpha: 0.12)
                  : Colors.white,
            ),
            const _ControlDivider(),
          ],
          _ControlButton(
            icon: Icons.my_location_rounded,
            tooltip: 'Mi ubicación',
            onPressed: onMyLocation,
            iconColor: _googleBlue,
          ),
          const _ControlDivider(),
          _ControlButton(
            icon: Icons.add_rounded,
            tooltip: 'Acercar',
            onPressed: onZoomIn,
          ),
          const _ControlDivider(),
          _ControlButton(
            icon: Icons.remove_rounded,
            tooltip: 'Alejar',
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}

class _ControlDivider extends StatelessWidget {
  const _ControlDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: MapFloatingControls._dividerColor,
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = const Color(0xFF5F6368),
    this.backgroundColor = Colors.white,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }
}
