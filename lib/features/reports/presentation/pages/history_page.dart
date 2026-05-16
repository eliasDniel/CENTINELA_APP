// RF-0308: History page
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_card_widget.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _selectedFilter = 'todos';
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);
        final isVisitor = authState.user?.isVisitor ?? false;
        final userId = authState.user?.uuid ?? '';

        return Scaffold(
          body: SafeArea(
            child: isVisitor
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Inicia sesión para ver tu historial',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/auth'),
                          child: const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: Consumer(
                      builder: (context, ref, _) {
                        final userReportsAsync = ref.watch(
                          userReportsProvider(userId),
                        );
                        return userReportsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error: $err')),
                          data: (reports) {
                            final filteredReports = _selectedFilter == 'todos'
                                ? reports
                                : reports
                                      .where((r) => r.type == _selectedFilter)
                                      .toList();

                            return ListView(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(
                                    AppConfig.horizontalMargin,
                                  ),
                                  child: Material(
                                    color: const Color(0xFF5B7FFF),
                                    borderRadius: BorderRadius.circular(50),
                                    child: InkWell(
                                      onTap: () => context.go('/report/new'),
                                      borderRadius: BorderRadius.circular(50),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Crear Nueva Alerta',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Filter Chips
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),

                                  child: Row(
                                    children: [
                                      _FilterChip(
                                        label: 'Todos ${reports.length}',
                                        isSelected: _selectedFilter == 'todos',
                                        onTap: () {
                                          setState(() {
                                            _selectedFilter = 'todos';
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label:
                                            'Robo ${reports.where((r) => r.type == 'robo').length}',
                                        isSelected: _selectedFilter == 'robo',
                                        onTap: () {
                                          setState(() {
                                            _selectedFilter = 'robo';
                                          });
                                        },
                                        color: const Color(0xFFFF3B30),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label:
                                            'Sospechoso ${reports.where((r) => r.type == 'sospechoso').length}',
                                        isSelected:
                                            _selectedFilter == 'sospechoso',
                                        onTap: () {
                                          setState(() {
                                            _selectedFilter = 'sospechoso';
                                          });
                                        },
                                        color: const Color(0xFFFFB800),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Reports List
                                if (filteredReports.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.description_outlined,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay reportes',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppConfig.horizontalMargin,
                                    ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredReports.length,
                                    itemBuilder: (context, index) {
                                      return ReportCardWidget(
                                        report: filteredReports[index],
                                      );
                                    },
                                  ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF5B7FFF))
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (color ?? const Color(0xFF5B7FFF)),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
