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

  /// `null` si el login fue exitoso; mensaje de error del backend en caso contrario.
  Future<String?> loginUser(String email, String password) async {
    try {
      final user = await _enrichWithZona(await authRepository.login(email, password));
      await _setLoggedUser(user);
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: null,
        errorMessage: e.message,
      );
      return e.message;
    }
  }

  /// `null` si el registro fue exitoso; mensaje de error del backend en caso contrario.
  Future<String?> registerUser({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  }) async {
    try {
      final ok = await authRepository.register(
        email: email,
        password: password,
        alias: alias,
        phone: phone,
        zonaId: zonaId,
      );
      if (!ok) {
        const fallback = 'No se pudo completar el registro';
        state = state.copyWith(errorMessage: fallback);
        return fallback;
      }
      state = state.copyWith(errorMessage: '');
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return e.message;
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
          final enriched = await _enrichWithZona(restored);
          state = state.copyWith(
            authStatus: AuthStatus.authenticated,
            user: enriched,
            errorMessage: '',
          );
          if (enriched.zonaNombre != restored.zonaNombre) {
            await keyValueStorageService.setKeyValue(
              AuthSessionKeys.userZonaNombre,
              enriched.zonaNombre ?? '',
            );
          }
          return;
        }
      }

      final user = await _enrichWithZona(await authRepository.checkStatus(refreshToken));
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
    final zonaNombre = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userZonaNombre,
    );
    final alias = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userAlias,
    );
    if (uuid == null || email == null || rol == null) return null;

    return UserEntity(
      uuid: uuid,
      email: email,
      rol: rol,
      token: accessToken,
      refreshToken: refreshToken,
      zonaId: zonaId ?? '',
      zonaNombre: zonaNombre,
      alias: alias ?? '',
    );
  }

  Future<UserEntity> _enrichWithZona(UserEntity user) async {
    if (user.zonaId.isEmpty) return user;
    if (user.zonaNombre != null && user.zonaNombre!.isNotEmpty) return user;

    try {
      final zonas = await authRepository.getZonas();
      for (final zona in zonas) {
        if (zona.id == user.zonaId) {
          return user.copyWith(zonaNombre: zona.nombre);
        }
      }
    } catch (_) {
      // Si falla la carga de zonas, la sesión sigue válida sin nombre.
    }
    return user;
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
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userZonaNombre,
      user.zonaNombre ?? '',
    );
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userAlias,
      user.alias,
    );

    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      errorMessage: '',
    );
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = state.user?.token;
    if (token == null || token.isEmpty) {
      return 'Inicia sesión para cambiar tu contraseña';
    }

    try {
      await authRepository.changePassword(
        accessToken: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(errorMessage: '');
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return e.message;
    } catch (_) {
      const fallback = 'No se pudo cambiar la contraseña';
      state = state.copyWith(errorMessage: fallback);
      return fallback;
    }
  }

  Future<String?> updatePrincipalZona({
    required String zonaId,
    required String zonaNombre,
  }) async {
    final current = state.user;
    if (current == null) {
      return 'Inicia sesión para cambiar tu zona';
    }

    final updated = current.copyWith(
      zonaId: zonaId,
      zonaNombre: zonaNombre,
    );

    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userZonaId,
      zonaId,
    );
    await keyValueStorageService.setKeyValue(
      AuthSessionKeys.userZonaNombre,
      zonaNombre,
    );

    state = state.copyWith(user: updated, errorMessage: '');
    return null;
  }

  Future<String?> deleteAccount() async {
    final token = state.user?.token;
    if (token == null || token.isEmpty) {
      return 'Inicia sesión para eliminar tu cuenta';
    }

    try {
      await authRepository.deleteAccount(token);
      await logoutUser();
      return null;
    } on CustomError catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo eliminar la cuenta';
    }
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
