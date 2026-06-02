// RF-0308: History page
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../../domain/constants/incident_types.dart';
import '../widgets/report_card_widget.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
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
                            int countByType(String type) => reports
                                .where((r) => r.type == type)
                                .length;

                            const statTypes = [
                              'robo',
                              'sicariato',
                              'sospechoso',
                              'accidente',
                            ];

                            return ListView(
                              padding: const EdgeInsets.all(0),
                              children: [
                                // Header Section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    24,
                                    24,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mi Historial',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Resumen de tus reportes de seguridad',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Stats Grid
                                Container(
                                  margin: const EdgeInsets.all(
                                    AppConfig.horizontalMargin,
                                  ),
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.5,
                                    shrinkWrap: true,

                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: statTypes
                                        .map(
                                          (type) => _StatCard(
                                            icon: incidentTypeIcon(type),
                                            iconColor: incidentTypeColor(type),
                                            number: '${countByType(type)}',
                                            label: incidentTypeLabel(type),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Recent Reports Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Reportes Recientes',
                                        style: TextStyle(
                                          color: Color(0xFF8A8A8E),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.filter_list,
                                          size: 16,
                                        ),
                                        label: const Text('Filtrar'),
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF1E90FF,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Reports List
                                if (reports.isEmpty)
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
                                            'No hay reportes aún',
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
                                    itemCount: reports.length,
                                    itemBuilder: (context, index) {
                                      return ReportCardWidget(
                                        report: reports[index],
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
          floatingActionButton: isVisitor
              ? null
              : FloatingActionButton(
                  onPressed: () => context.push('/home/2/report/new'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  backgroundColor: AppConfig.primary,
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String number;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A8A8E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
