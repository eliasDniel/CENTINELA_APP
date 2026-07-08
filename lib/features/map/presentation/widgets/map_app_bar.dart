import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/map_provider.dart';

class MapAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MapAppBar({
    super.key,
    required this.onRefresh,
    required this.onOpenFilters,
  });

  final VoidCallback onRefresh;
  final VoidCallback onOpenFilters;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(mapProvider.select((s) => s.isLoading));
    final counts = ref.watch(mapAlertCountsProvider);
    final hasActiveFilters = ref.watch(mapHasActiveFiltersProvider);

    final subtitle = counts.total == 0
        ? 'Sin alertas en las últimas 24 h'
        : '${counts.total} en mapa · ${counts.active} activa${counts.active == 1 ? '' : 's'} · ${counts.resolved} atendida${counts.resolved == 1 ? '' : 's'} (24 h)';

    return AppBar(
      backgroundColor: AppConfig.surface.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mapa de alertas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppConfig.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: isLoading ? null : onRefresh,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar alertas',
        ),
        IconButton(
          onPressed: onOpenFilters,
          tooltip: 'Filtrar alertas',
          icon: Badge(
            isLabelVisible: hasActiveFilters,
            smallSize: 8,
            backgroundColor: AppConfig.sos,
            child: const Icon(Icons.tune_rounded),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
