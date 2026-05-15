// RF-0305: Offline banner widget
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class OfflineBannerWidget extends StatelessWidget {
  const OfflineBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppConfig.error,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppConfig.textPrimary, size: 20),
          const SizedBox(width: 12),
          Text(
            'Sin conexión — Los SOS se guardan localmente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
