// RF: Router configuration with all routes
import 'package:centinela_milagro/features/reports/presentation/pages/report_page.dart';
import 'package:centinela_milagro/features/reports/presentation/pages/report_detail_page.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/core/presentation/pages/shell_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_hub_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_manage_page.dart';
import '../../features/notifications/presentation/notifications_screens.dart';
import '../../features/reports/presentation/pages/offline_queue_page.dart';
import '../../features/profile/presentation/pages/privacy_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/change_location_page.dart';

// Custom page transition - fade in/out
Page<dynamic> _fadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _fadeTransition(context, state, const SplashPage()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _fadeTransition(context, state, const OnboardingPage()),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) =>
          _fadeTransition(context, state, const AuthPage()),
      routes: [
        GoRoute(
          path: ForgotPasswordPage.routeName,
          name: ForgotPasswordPage.routeName,
          pageBuilder: (context, state) => _fadeTransition(
            context,
            state,
            const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          path: ResetPasswordPage.routeName,
          name: ResetPasswordPage.routeName,
          pageBuilder: (context, state) => _fadeTransition(
            context,
            state,
            const ResetPasswordPage(),
          ),
        ),
      ],
    ),

    GoRoute(
      path: '/home/:page',
      pageBuilder: (context, state) {
        return _fadeTransition(
          context,
          state,
          ShellPage(
            pageIndex: int.parse(state.pathParameters['page'] ?? '0'),
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'report/new',
          name: ReportPage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(context, state, const ReportPage());
          },
        ),
        GoRoute(
          path: '${ReportDetailPage.routeName}/:reportId',
          name: ReportDetailPage.routeName,
          pageBuilder: (context, state) {
            final report = state.extra as ReportEntity;
            return _fadeTransition(
              context,
              state,
              ReportDetailPage(report: report),
            );
          },
        ),
        GoRoute(
          path: NotificationsScreen.routeName,
          name: NotificationsScreen.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(
              context,
              state,
              const NotificationsScreen(),
            );
          },
        ),
        GoRoute(
          path: OfflineQueuePage.routeName,
          name: OfflineQueuePage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(
              context,
              state,
              const OfflineQueuePage(),
            );
          },
        ),
        GoRoute(
          path: ChangePasswordPage.routeName,
          name: ChangePasswordPage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(
              context,
              state,
              const ChangePasswordPage(),
            );
          },
        ),
        GoRoute(
          path: ChangeLocationPage.routeName,
          name: ChangeLocationPage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(
              context,
              state,
              const ChangeLocationPage(),
            );
          },
        ),
        GoRoute(
          path: PrivacyPage.routeName,
          name: PrivacyPage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(context, state, const PrivacyPage());
          },
        ),
        GoRoute(
          path: SubscriptionsHubPage.routeName,
          name: SubscriptionsHubPage.routeName,
          pageBuilder: (context, state) {
            return _fadeTransition(
              context,
              state,
              const SubscriptionsHubPage(),
            );
          },
          routes: [
            GoRoute(
              path: 'manage',
              name: SubscriptionsManagePage.routeName,
              pageBuilder: (context, state) {
                return _fadeTransition(
                  context,
                  state,
                  const SubscriptionsManagePage(),
                );
              },
            ),
          ],
        ),
      ],
    ),

  ],
);