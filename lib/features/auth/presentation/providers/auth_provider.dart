// RF-0301, RF-0302: Auth state and notifier for Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_as_visitor_usecase.dart';
import '../../infrastructure/datasources/auth_local_datasource.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository repository;

  @override
  AuthState build() {
    repository = ref.watch(authRepositoryProvider);
    return AuthState();
  }

  Future<void> login(String alias, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginUseCase = LoginUseCase(repository);
      final user = await loginUseCase(alias, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> register(String alias, String password, String barrio,
      {String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final registerUseCase = RegisterUseCase(repository);
      final user = await registerUseCase(alias, password, barrio, phone: phone);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> loginAsVisitor() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginAsVisitorUseCase = LoginAsVisitorUseCase(repository);
      final user = await loginAsVisitorUseCase();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  void logout() {
    state = AuthState();
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthLocalDataSource();
  return AuthRepositoryImpl(dataSource);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
