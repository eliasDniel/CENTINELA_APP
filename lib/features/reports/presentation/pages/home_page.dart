// RF-0304, RF-0305, RF-0307: Home page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/sos_button_widget.dart';
import '../widgets/offline_banner_widget.dart';
import '../widgets/report_card_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final recentReportsAsync = ref.watch(recentReportsProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final offlineNotifier = ref.read(isOfflineProvider.notifier);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.shield_moon_outlined, color: Colors.white),
        title: const Text('BarrioSeguro'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isOffline ? Icons.wifi_off : Icons.wifi),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Modo offline'),
                        subtitle: const Text('Simular desconexión'),
                        trailing: Switch(
                          value: isOffline,
                          onChanged: (value) {
                            offlineNotifier.toggleOffline(value);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isOffline) const OfflineBannerWidget(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // SOS Button
                  SizedBox(
                    height: size.height * 0.2,
                    child: Center(
                      child: SOSButtonWidget(
                        onPressed: () {
                          if (isOffline) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '📴 SOS guardado localmente. Se enviará al reconectar',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Alerts section
                  Text(
                    'Alertas en tu barrio',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  recentReportsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, stack) => Text('Error: $err'),
                    data: (reports) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reports.take(3).length,
                        itemBuilder: (context, index) {
                          return ReportCardWidget(report: reports[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
