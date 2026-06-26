import 'package:flutter/material.dart';

/// Inset inferior del sistema (barra de gestos / home indicator).
double bottomViewInset(BuildContext context) =>
    MediaQuery.viewPaddingOf(context).bottom;

/// Inset superior del sistema (notch / barra de estado).
double topViewInset(BuildContext context) =>
    MediaQuery.viewPaddingOf(context).top;

/// Envuelve barras inferiores (nav, botones fijos) respetando edge-to-edge.
class SafeBottomBar extends StatelessWidget {
  const SafeBottomBar({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(padding: padding, child: child),
    );
  }
}
