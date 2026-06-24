// Indicador compacto de filtros activos en el mapa
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_colors.dart';
import '../providers/map_provider.dart';

class MapActiveFiltersBanner extends ConsumerWidget {
  const MapActiveFiltersBanner({
    super.key,
    required this.onTap,
    required this.onClear,
  });

  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(mapActiveFiltersSummaryProvider);
    if (summary == null) return const SizedBox.shrink();

    return Material(
      color: AppConfig.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      elevation: 3,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, color: AppConfig.primary, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppConfig.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
