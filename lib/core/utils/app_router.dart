import 'package:centinela_milagro/core/utils/router_notifier.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/auth_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/reset_password_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/splash_page.dart';
import 'package:centinela_milagro/features/core/presentation/pages/shell_page.dart';
import 'package:centinela_milagro/features/notifications/presentation/notifications_screens.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/change_location_page.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/change_password_page.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/privacy_page.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/offline_queue_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/report_detail_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/report_page.dart';
import 'package:centinela_milagro/features/subscriptions/presentation/pages/subscriptions_hub_page.dart';
import 'package:centinela_milagro/features/subscriptions/presentation/pages/subscriptions_manage_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      // Splash
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      // Auth
      GoRoute(path: '/login', builder: (context, state) => const AuthPage()),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // App principal
      GoRoute(
        path: '/home/:page',
        builder: (context, state) => ShellPage(
          pageIndex: int.parse(state.pathParameters['page'] ?? '0'),
        ),
        routes: [
          GoRoute(
            path: 'notifications',
            name: NotificationsScreen.routeName,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'report/new',
            name: ReportPage.routeName,
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: 'report/:reportId',
            name: ReportDetailPage.routeName,
            builder: (context, state) {
              final report = state.extra as ReportEntity;
              return ReportDetailPage(report: report);
            },
          ),
          GoRoute(
            path: 'subscriptions',
            name: SubscriptionsHubPage.routeName,
            builder: (context, state) => const SubscriptionsHubPage(),
            routes: [
              GoRoute(
                path: 'manage',
                name: SubscriptionsManagePage.routeName,
                builder: (context, state) => const SubscriptionsManagePage(),
              ),
            ],
          ),
          GoRoute(
            path: 'change-password',
            name: ChangePasswordPage.routeName,
            builder: (context, state) => const ChangePasswordPage(),
          ),
          GoRoute(
            path: 'change-location',
            name: ChangeLocationPage.routeName,
            builder: (context, state) => const ChangeLocationPage(),
          ),
          GoRoute(
            path: 'privacy',
            name: PrivacyPage.routeName,
            builder: (context, state) => const PrivacyPage(),
          ),
          GoRoute(
            path: 'offline-queue',
            name: OfflineQueuePage.routeName,
            builder: (context, state) => const OfflineQueuePage(),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      // Splash: esperar mientras verifica
      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      // No autenticado: solo puede ir a login, register, forgot/reset password
      if (authStatus == AuthStatus.unauthenticated) {
        final allowedRoutes = [
          '/login',
          '/register',
          '/forgot-password',
          '/reset-password',
        ];
        if (allowedRoutes.contains(isGoingTo)) return null;
        return '/login';
      }

      // Autenticado: no puede volver a auth screens
      if (authStatus == AuthStatus.authenticated) {
        final authRoutes = ['/login', '/register', '/splash'];
        if (authRoutes.contains(isGoingTo)) return '/home/0';
      }

      return null;
    },
  );
});
