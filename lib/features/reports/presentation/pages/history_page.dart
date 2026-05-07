// RF-0308: History page
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
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);
        final isVisitor = authState.user?.isVisitor ?? false;
        final userId = authState.user?.uuid ?? '';

        return Scaffold(
          appBar: AppBar(title: const Text('Mi Historial')),
          body: isVisitor
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
                    // Simulate refresh delay
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Consumer(
                    builder: (context, ref, _) {
                      final userReportsAsync =
                          ref.watch(userReportsProvider(userId));
                      return userReportsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (err, stack) => Center(
                          child: Text('Error: $err'),
                        ),
                        data: (reports) {
                          if (reports.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay reportes aún',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: reports.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              return ReportCardWidget(
                                  report: reports[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
