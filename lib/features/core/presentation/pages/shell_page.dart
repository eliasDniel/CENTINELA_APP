import 'package:centinela_milagro/core/utils/view_insets.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/map/presentation/pages/map_page.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/profile_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/history_page.dart';
import 'package:centinela_milagro/features/reports/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends ConsumerStatefulWidget {
  final int pageIndex;
  static const String name = 'home';
  const ShellPage({super.key, required this.pageIndex});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage>
    with AutomaticKeepAliveClientMixin {
  final List<Widget?> _tabs = List<Widget?>.filled(4, null);

  @override
  void initState() {
    super.initState();
    _ensureTabBuilt(widget.pageIndex);
  }

  @override
  void didUpdateWidget(ShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _ensureTabBuilt(widget.pageIndex);
    }
  }

  void _ensureTabBuilt(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs[index] ??= switch (index) {
      0 => const HomePage(),
      1 => const MapPage(),
      2 => const HistoryPage(),
      3 => const ProfilePage(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _tabBody(int index) {
    if (_tabs[index] == null) {
      return const SizedBox.shrink();
    }
    return TickerMode(
      enabled: index == widget.pageIndex,
      child: _tabs[index]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isVisitor = ref.watch(authProvider).user?.isVisitor ?? false;
    if (isVisitor) {
      return const Scaffold(
        body: MapPage(),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: widget.pageIndex,
        children: List.generate(_tabs.length, _tabBody),
      ),
      bottomNavigationBar: SafeBottomBar(
        child: BottomNavigationBar(
          currentIndex: widget.pageIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home/0');
                break;
              case 1:
                context.go('/home/1');
                break;
              case 2:
                context.go('/home/2');
                break;
              case 3:
                context.go('/home/3');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Ver Alertas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
