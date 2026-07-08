// RF-0308: History page
import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/incident_types.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_card_widget.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: kIncidentTypes.length + 1,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadReports();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final filter = _tabController.index == 0
        ? ''
        : kIncidentTypes[_tabController.index - 1]['value']!;

    ref.read(reportTypeFilterProvider.notifier).state = filter;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _loadReports() {
    if (ref.read(authProvider).user != null) {
      ref.read(reportsProvider.notifier).loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final selectedFilter = ref.watch(reportTypeFilterProvider);
    final reportsState = ref.watch(reportsProvider);
    final reports = ref.watch(reportsFilteredProvider(selectedFilter));
    final isVisitor = ref.watch(authProvider).user == null;

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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: size.height * 0.10,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalMargin,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mi Historial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
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
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppConfig.primary,
                    unselectedLabelColor: Colors.white54,
                    indicatorColor: AppConfig.primary,
                    dividerColor: Colors.white12,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: [
                      const Tab(text: 'Todos'),
                      ...kIncidentTypes.map(
                        (type) => Tab(text: type['label']),
                      ),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (!mounted) return;
                        if (ref.read(authProvider).user != null) {
                          await ref
                              .read(reportsProvider.notifier)
                              .loadHistory();
                        }
                      },
                      child: _buildReportsBody(
                        context,
                        reportsState: reportsState,
                        reports: reports,
                        hasFilter: selectedFilter.isNotEmpty,
                      ),
                    ),
                  ),
                ],
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
  }

  Widget _buildReportsBody(
    BuildContext context, {
    required ReportsState reportsState,
    required List<ReportEntity> reports,
    required bool hasFilter,
  }) {
    if (reportsState.isLoading && reportsState.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reportsState.errorMessage.isNotEmpty &&
        reportsState.reports.isEmpty) {
      return Center(child: Text('Error: ${reportsState.errorMessage}'));
    }

    if (reports.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No hay reportes aún')),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppConfig.horizontalMargin - 10,
        vertical: AppConfig.horizontalMargin - 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) =>
          ReportCardWidget(report: reports[index]),
    );
  }
}
