import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeLocationCardWidget extends ConsumerWidget {
  const HomeLocationCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isVisitor = user == null;
    final locationLine = _buildLocationLine(
      isVisitor: isVisitor,
      zonaNombre: user?.zonaNombre,
    );

    return Card(
      margin: const EdgeInsets.all(AppConfig.horizontalMargin),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppConfig.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/home/1'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF42A5F5),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVisitor ? 'Tu ubicación (aprox.)' : 'Tu ubicación',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationLine,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConfig.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isVisitor
                          ? 'Toca para ver alertas cerca de ti en el mapa'
                          : 'Ver alertas en el mapa',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppConfig.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  String _buildLocationLine({
    required bool isVisitor,
    String? zonaNombre,
  }) {
    const cityCountry = 'Milagro, Ecuador';

    if (isVisitor) {
      return cityCountry;
    }

    final zona = zonaNombre?.trim();
    if (zona == null || zona.isEmpty) {
      return 'Sin zona principal · $cityCountry';
    }

    return '$zona · $cityCountry';
  }
}
