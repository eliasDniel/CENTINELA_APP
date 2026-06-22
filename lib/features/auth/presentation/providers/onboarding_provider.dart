import 'package:centinela_milagro/features/auth/presentation/providers/services/key_value_storage_impl.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/services/key_value_storage.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract final class OnboardingKeys {
  static const completed = 'onboarding_completed';
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
      return OnboardingNotifier(KeyValueStorageImpl());
    });

class OnboardingNotifier extends StateNotifier<bool?> {
  final KeyValueStorageService _storage;

  OnboardingNotifier(this._storage) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final completed = await _storage.getValue<bool>(OnboardingKeys.completed);
    state = completed ?? false;
  }

  Future<void> complete() async {
    await _storage.setKeyValue(OnboardingKeys.completed, true);
    state = true;
  }
}
