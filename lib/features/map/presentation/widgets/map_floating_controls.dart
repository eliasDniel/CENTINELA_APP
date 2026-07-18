import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controles flotantes del mapa al estilo Google Maps, adaptados al tema oscuro.
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
    this.onFilter,
  });

  final bool compassActive;
  final bool compassAvailable;
  final bool showCompass;
  final VoidCallback onCompass;
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback? onFilter;

  static const _controlSize = 48.0;
  static const _groupGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (onFilter != null) ...[
          _MapControlCircle(
            icon: Icons.tune_rounded,
            tooltip: 'Filtrar alertas',
            accent: true,
            onPressed: onFilter,
          ),
          const SizedBox(height: _groupGap),
        ],
        if (showCompass && compassAvailable) ...[
          _MapControlCircle(
            icon: Icons.explore_rounded,
            tooltip: 'Modo brújula',
            active: compassActive,
            onPressed: onCompass,
          ),
          const SizedBox(height: _groupGap),
        ],
        _MapControlPill(
          children: [
            _MapControlTile(
              icon: Icons.add_rounded,
              tooltip: 'Acercar',
              onPressed: onZoomIn,
            ),
            const _MapControlDivider(),
            _MapControlTile(
              icon: Icons.remove_rounded,
              tooltip: 'Alejar',
              onPressed: onZoomOut,
            ),
          ],
        ),
        const SizedBox(height: _groupGap),
        _MapControlCircle(
          icon: Icons.my_location_rounded,
          tooltip: 'Mi ubicación',
          accent: true,
          onPressed: onMyLocation,
        ),
      ],
    );
  }
}

class _MapControlSurface extends StatelessWidget {
  const _MapControlSurface({
    required this.child,
    required this.shape,
  });

  final Widget child;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppConfig.surface.withValues(alpha: 0.94),
      elevation: 3,
      shadowColor: Colors.black54,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _MapControlCircle extends StatelessWidget {
  const _MapControlCircle({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    this.accent = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? AppConfig.primaryLight
        : accent
        ? AppConfig.primaryLight
        : AppConfig.textSecondary;

    return _MapControlSurface(
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: _MapControlTile(
        icon: icon,
        tooltip: tooltip,
        onPressed: onPressed,
        iconColor: iconColor,
        backgroundColor: active
            ? AppConfig.primary.withValues(alpha: 0.22)
            : Colors.transparent,
      ),
    );
  }
}

class _MapControlPill extends StatelessWidget {
  const _MapControlPill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _MapControlSurface(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _MapControlDivider extends StatelessWidget {
  const _MapControlDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppConfig.divider.withValues(alpha: 0.6),
    );
  }
}

class _MapControlTile extends StatelessWidget {
  const _MapControlTile({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = AppConfig.textSecondary,
    this.backgroundColor = Colors.transparent,
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
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: SizedBox(
          width: MapFloatingControls._controlSize,
          height: MapFloatingControls._controlSize,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }
}
