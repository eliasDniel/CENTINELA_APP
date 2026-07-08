// RF-0305: SOS button widget with pulse animation
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

import 'sos_confirm_dialog.dart';

class SOSButtonWidget extends StatefulWidget {
  final Future<void> Function() onEmergencySent;

  const SOSButtonWidget({super.key, required this.onEmergencySent});

  @override
  State<SOSButtonWidget> createState() => _SOSButtonWidgetState();
}

class _SOSButtonWidgetState extends State<SOSButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scale;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    
    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Pulse animation for outer ring
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
        // Pulse ring animation
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Container(
              width: 270 + (_pulse.value * 60),
              height: 270 + (_pulse.value * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConfig.error.withOpacity(0.18 - (_pulse.value * 0.14)),
                  width: 2,
                ),
              ),
            );
          },
        ),
        // Outer container
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.error.withOpacity(0.08),
            border: Border.all(
              color: AppConfig.error.withOpacity(0.18),
              width: 2,
            ),
          ),
        ),
        // Inner container
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.error.withOpacity(0.14),
            border: Border.all(
              color: AppConfig.error.withOpacity(0.25),
              width: 2,
            ),
          ),
        ),
        // Main button with scale animation
        ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTap: () async {
              final confirmed = await SosConfirmDialog.show(context);
              if (confirmed == true) {
                await widget.onEmergencySent();
              }
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppConfig.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConfig.error.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded, size: 32, color: Colors.white),
                  const SizedBox(height: 6),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white
                    ),
                  ),
                  const Text(
                    'EMERGENCIA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white70
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
