import 'package:centinela_milagro/core/utils/router_notifier.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/auth_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/reset_password_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/onboarding_page.dart';
import 'package:centinela_milagro/features/auth/presentation/screens/splash_page.dart';
import 'package:centinela_milagro/features/core/presentation/pages/shell_page.dart';
import 'package:centinela_milagro/features/notifications/presentation/notifications_screens.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/change_location_page.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/change_password_page.dart';
import 'package:centinela_milagro/features/profile/presentation/pages/privacy_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/offline_queue_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/report_detail_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/report_page.dart';
import 'package:centinela_milagro/features/subscriptions/presentation/pages/subscriptions_hub_page.dart';
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
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordPage(resetToken: token);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
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
              
              final reportId = state.pathParameters['reportId'] ?? '';
              return ReportDetailPage(reportId: reportId);
            },
          ),
          GoRoute(
            path: 'subscriptions',
            name: SubscriptionsHubPage.routeName,
            builder: (context, state) => const SubscriptionsHubPage(),
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
      final onboardingCompleted = goRouterNotifier.onboardingCompleted;

      if (authStatus == AuthStatus.checking || onboardingCompleted == null) {
        if (isGoingTo == '/splash') return null;
        if (isGoingTo.startsWith('/reset-password') ||
            isGoingTo == '/forgot-password') {
          return null;
        }
        return '/splash';
      }

      if (authStatus == AuthStatus.unauthenticated) {
        if (isGoingTo.startsWith('/reset-password') ||
            isGoingTo == '/forgot-password' ||
            isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/onboarding') {
          return null;
        }
        if (isGoingTo == '/splash') {
          return onboardingCompleted ? '/login' : '/onboarding';
        }
        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        const authRoutes = [
          '/login',
          '/register',
          '/splash',
          '/onboarding',
        ];
        if (goRouterNotifier.isVisitor) {
          if (authRoutes.contains(isGoingTo)) return '/home/1';
          if (isGoingTo.startsWith('/home/') && isGoingTo != '/home/1') {
            return '/home/1';
          }
        } else {
          if (authRoutes.contains(isGoingTo)) return '/home/0';
        }
        if (isGoingTo.startsWith('/reset-password') ||
            isGoingTo == '/forgot-password') {
          return null;
        }
      }

      return null;
    },
    
  );
});
