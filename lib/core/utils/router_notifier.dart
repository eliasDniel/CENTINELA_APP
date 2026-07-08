import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterNotifierProvider = Provider((ref) {
  final auth = ref.read(authProvider);
  final notifier = GoRouterNotifier(
    authStatus: auth.authStatus,
    onboardingCompleted: ref.read(onboardingCompletedProvider),
    isVisitor: auth.user?.isVisitor ?? false,
  );

  ref.listen(authProvider, (_, next) {
    notifier.updateAuthStatus(next.authStatus);
    notifier.updateIsVisitor(next.user?.isVisitor ?? false);
  });

  ref.listen(onboardingCompletedProvider, (_, next) {
    notifier.updateOnboardingCompleted(next);
  });

  return notifier;
});

class GoRouterNotifier extends ChangeNotifier {
  AuthStatus _authStatus;
  bool? _onboardingCompleted;
  bool _isVisitor;

  GoRouterNotifier({
    required AuthStatus authStatus,
    required bool? onboardingCompleted,
    required bool isVisitor,
  })  : _authStatus = authStatus,
        _onboardingCompleted = onboardingCompleted,
        _isVisitor = isVisitor;

  AuthStatus get authStatus => _authStatus;
  bool? get onboardingCompleted => _onboardingCompleted;
  bool get isVisitor => _isVisitor;

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

  void updateIsVisitor(bool value) {
    if (_isVisitor == value) return;
    _isVisitor = value;
    notifyListeners();
  }
}
