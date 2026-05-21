// RF: Router configuration with all routes
import 'package:centinela_milagro/features/reports/presentation/pages/report_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/core/presentation/pages/shell_page.dart';

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
    ),
    ShellRoute(
      builder: (context, state, child) {
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        return ShellPage(pageIndex: pageIndex);
      },
      routes: [
        GoRoute(
          path: '/home/:page',
          builder: (context, state) {
            final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
            return ShellPage(pageIndex: pageIndex);
          },
          routes: [
            GoRoute(
              path: 'report/new', 
              builder: (context, state) => ReportPage(),
            )
          ]
        ),
      ],
    ),
  ],
);
