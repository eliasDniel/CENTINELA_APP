import 'package:centinela_milagro/features/auth/infrastructure/utils/access_token.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_session_keys.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/services/key_value_storage_impl.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import 'services/key_value_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final keyValueStorageService = KeyValueStorageImpl();
  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  bool _isCheckingAuth = false;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final user = await authRepository.login(email, password);
      await _setLoggedUser(user);
      return true;
    } on CustomError catch (e) {
      logoutUser(e.message);
      return false;
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  }) async {
    try {
      final message = await authRepository.register(
        email: email,
        password: password,
        alias: alias,
        phone: phone,
        zonaId: zonaId,
      );
      return message;
    } on CustomError catch (e) {
      logoutUser(e.message);
      return false;
    }
  }

  void checkAuthStatus() async {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;

    try {
      final refreshToken = await keyValueStorageService.getValue<String>(
        AuthSessionKeys.refreshToken,
      );
      if (refreshToken == null) {
        return logoutUser();
      }

      final accessToken = await keyValueStorageService.getValue<String>(
        AuthSessionKeys.token,
      );

      // Hot reload / re-apertura: no rotar el refresh si el JWT aún es válido.
      if (accessToken != null && isAccessTokenValid(accessToken)) {
        final restored = await _restoreUserFromStorage(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        if (restored != null) {
          state = state.copyWith(
            authStatus: AuthStatus.authenticated,
            user: restored,
            errorMessage: '',
          );
          return;
        }
      }

      final user = await authRepository.checkStatus(refreshToken);
      await _setLoggedUser(user);
    } catch (e) {
      if (e is CustomError && e.message == 'Revisar conexión') {
        final offline = await _tryRestoreOfflineSession();
        if (offline != null) {
          state = state.copyWith(
            authStatus: AuthStatus.authenticated,
            user: offline,
            errorMessage: '',
          );
          return;
        }
      }

      final recovered = await _tryRecoverSessionAfterRefreshRace();
      if (recovered == null) {
        logoutUser();
      }
    } finally {
      _isCheckingAuth = false;
    }
  }

  Future<UserEntity?> _tryRestoreOfflineSession() async {
    final accessToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    final refreshToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.refreshToken,
    );
    if (accessToken == null || refreshToken == null) return null;
    if (!isAccessTokenValid(accessToken)) return null;

    return _restoreUserFromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<UserEntity?> _tryRecoverSessionAfterRefreshRace() async {
    final accessToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    final refreshToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.refreshToken,
    );
    if (accessToken == null || refreshToken == null) return null;
    if (!isAccessTokenValid(accessToken)) return null;

    final recovered = await _restoreUserFromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    if (recovered == null) return null;

    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: recovered,
      errorMessage: '',
    );
    return recovered;
  }

  Future<UserEntity?> _restoreUserFromStorage({
    required String accessToken,
    required String refreshToken,
  }) async {
    final uuid = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userUuid,
    );
    final email = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userEmail,
    );
    final rol = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userRol,
    );
    final zonaId = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userZonaId,
    );

    if (uuid == null || email == null || rol == null) return null;

    return UserEntity(
      uuid: uuid,
      email: email,
      rol: rol,
      token: accessToken,
      refreshToken: refreshToken,
      zonaId: zonaId ?? '',
    );
  }

  Future<void> _setLoggedUser(UserEntity user) async {
    await keyValueStorageService.setKeyValue(AuthSessionKeys.token, user.token);
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.refreshToken,
      user.refreshToken,
    );
    await keyValueStorageService.setKeyValue(AuthSessionKeys.userUuid, user.uuid);
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userEmail,
      user.email,
    );
    await keyValueStorageService.setKeyValue(AuthSessionKeys.userRol, user.rol);
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userZonaId,
      user.zonaId,
    );

    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      errorMessage: '',
    );
  }

  Future<void> logoutUser([String? errorMessage]) async {
    final refreshToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.refreshToken,
    );
    if (refreshToken != null) {
      try {
        await authRepository.logout(refreshToken);
      } catch (_) {
        // Si la sesión ya expiró, igual limpiamos el almacenamiento local.
      }
    }

    await _clearStoredSession();

    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      user: null,
      errorMessage: errorMessage ?? '',
    );
  }

  Future<void> _clearStoredSession() async {
    for (final key in AuthSessionKeys.all) {
      await keyValueStorageService.removeKey(key);
    }
  }
}

enum AuthStatus { authenticated, unauthenticated, checking }

class AuthState {
  final AuthStatus authStatus;
  final UserEntity? user;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    UserEntity? user,
    String? errorMessage,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
