import 'package:centinela_milagro/core/utils/view_insets.dart';
import 'package:centinela_milagro/core/location/user_location_provider.dart';
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
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(keepPage: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final viewsPages = const <Widget>[
    HomePage(),
    MapPage(),
    HistoryPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(userLocationProvider);
    if (pageController.hasClients) {
      pageController.animateToPage(
        widget.pageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        children: viewsPages,
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