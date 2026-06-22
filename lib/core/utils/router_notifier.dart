import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterNotifierProvider = Provider((ref) {
  final notifier = GoRouterNotifier(
    authStatus: ref.read(authProvider).authStatus,
    onboardingCompleted: ref.read(onboardingCompletedProvider),
  );

  ref.listen(authProvider, (_, next) {
    notifier.updateAuthStatus(next.authStatus);
  });

  ref.listen(onboardingCompletedProvider, (_, next) {
    notifier.updateOnboardingCompleted(next);
  });

  return notifier;
});

class GoRouterNotifier extends ChangeNotifier {
  AuthStatus _authStatus;
  bool? _onboardingCompleted;

  GoRouterNotifier({
    required AuthStatus authStatus,
    required bool? onboardingCompleted,
  })  : _authStatus = authStatus,
        _onboardingCompleted = onboardingCompleted;

  AuthStatus get authStatus => _authStatus;
  bool? get onboardingCompleted => _onboardingCompleted;

  void updateAuthStatus(AuthStatus value) {
    if (_authStatus == value) return;
    _authStatus = value;
    notifyListeners();
  }

  void updateOnboardingCompleted(bool? value) {
    if (_onboardingCompleted == value) return;
    _onboardingCompleted = value;
    notifyListeners();
  }
}
