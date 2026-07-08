// RF-0304, RF-0305, RF-0307: Home screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/blocs/notifications/notifications_bloc.dart';
import '../providers/sos_provider.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_location_card_widget.dart';
import '../widgets/home_sos_section_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    final auth = ref.read(authProvider);
    final user = auth.user;
    if (user == null || user.isVisitor) return;

    final token = await ref.read(authProvider.notifier).resolveAccessToken();
    if (!mounted || token == null || token.isEmpty) return;

    context.read<NotificationsBloc>().add(NotificationsLoadHistory(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            HomeSosSectionWidget(
              onEmergencySent: () => handleSosSent(context),
            ),
            const HomeLocationCardWidget(),
          ],
        ),
      ),
    );
  }
}
