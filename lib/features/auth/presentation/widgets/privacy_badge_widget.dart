// RF-0301: Privacy badge widget
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class PrivacyBadgeWidget extends StatelessWidget {
  final String uuid;

  const PrivacyBadgeWidget({Key? key, required this.uuid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppConfig.primary),
        borderRadius: BorderRadius.circular(8),
        color: AppConfig.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, color: AppConfig.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Tu identidad protegida',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConfig.primary,
                ),
          ),
        ],
      ),
    );
  }
}
