import 'package:centinela_milagro/core/notifications/fcm_token_registry.dart';
import 'package:centinela_milagro/core/notifications/notification_preferences.dart';
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
  int _sessionGeneration = 0;
  String? _registeredFcmToken;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  /// Ingreso sin cuenta: solo mapa con alertas cercanas (RF-0205).
  Future<void> loginAsVisitor() async {
    _sessionGeneration++;
    _registeredFcmToken = null;
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: UserEntity(
        uuid: 'visitante',
        alias: 'Visitante',
        email: '',
        rol: 'visitante',
        token: '',
        refreshToken: '',
        zonaId: '',
      ),
      errorMessage: '',
    );
  }

  /// `null` si el login fue exitoso; mensaje de error del backend en caso contrario.
  Future<String?> loginUser(String email, String password) async {
    _sessionGeneration++;
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

    final currentToken = state.user?.token;
    if (state.authStatus == AuthStatus.authenticated &&
        currentToken != null &&
        currentToken.isNotEmpty &&
        isAccessTokenValid(currentToken)) {
      return;
    }

    _isCheckingAuth = true;
    final generationAtStart = _sessionGeneration;

    try {
      final refreshToken = await keyValueStorageService.getValue<String>(
        AuthSessionKeys.refreshToken,
      );
      if (refreshToken == null) {
        if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
        if (state.authStatus == AuthStatus.authenticated) return;
        await logoutUser(onlyIfGeneration: generationAtStart);
        return;
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
          if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
          final enriched = await _enrichWithZona(restored);
          if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
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
          _applyPushPreference();
          return;
        }
      }

      if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;

      final user = await _enrichWithZona(await authRepository.checkStatus(refreshToken));
      if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
      await _setLoggedUser(user);
    } catch (e) {
      if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
      if (state.authStatus == AuthStatus.authenticated) return;

      if (e is CustomError && e.message == 'Revisar conexión') {
        final offline = await _tryRestoreOfflineSession();
        if (offline != null) {
          if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
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
        if (_shouldIgnoreStaleAuthCheck(generationAtStart)) return;
        if (state.authStatus == AuthStatus.authenticated) return;
        await logoutUser(onlyIfGeneration: generationAtStart);
      }
    } finally {
      _isCheckingAuth = false;
    }
  }

  bool _shouldIgnoreStaleAuthCheck(int generationAtStart) {
    return generationAtStart != _sessionGeneration ||
        state.authStatus == AuthStatus.authenticated;
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

  Future<void> _setLoggedUser(UserEntity user, {bool syncFcm = true}) async {
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

    if (NotificationPreferences.enabled) {
      final fcm = FcmTokenRegistry.token;
      if (fcm != null && fcm.isNotEmpty) {
        _registeredFcmToken = fcm;
      }
    }

    if (syncFcm) {
      _applyPushPreference();
    }
  }

  Future<void> _applyPushPreference() async {
    if (!NotificationPreferences.enabled) {
      await disablePushNotifications();
    }
    // El FCM se envía en login/refresh (_authPayload) o cuando FcmAuthSync
    // obtiene el token tras conceder permisos. Evita un refresh extra al entrar.
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

  Future<void> syncFcmWithBackend() async {
    if (state.authStatus != AuthStatus.authenticated) return;
    if (state.user?.isVisitor ?? false) return;
    if (!NotificationPreferences.enabled) return;

    final fcm = FcmTokenRegistry.token;
    if (fcm == null || fcm.isEmpty) return;
    if (fcm == _registeredFcmToken) return;

    final generationAtStart = _sessionGeneration;
    final accessToken = await resolveAccessToken();

    if (accessToken != null) {
      try {
        await authRepository.registerPushNotifications(
          accessToken: accessToken,
          fcmToken: fcm,
        );
        if (generationAtStart != _sessionGeneration) return;
        _registeredFcmToken = fcm;
        return;
      } catch (_) {
        // Si falla el registro ligero, se intenta refresh más abajo.
      }
    }

    final refreshToken = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.refreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) return;
    if (generationAtStart != _sessionGeneration) return;

    try {
      final user = await _enrichWithZona(
        await authRepository.checkStatus(refreshToken),
      );
      if (generationAtStart != _sessionGeneration) return;
      await _setLoggedUser(user, syncFcm: false);
      _registeredFcmToken = fcm;
    } catch (_) {
      // El token se sincronizará en el próximo refresh de sesión.
    }
  }

  Future<void> disablePushNotifications() async {
    if (state.authStatus != AuthStatus.authenticated) return;

    final accessToken = state.user?.token;
    final fcm = FcmTokenRegistry.token;
    if (accessToken == null ||
        accessToken.isEmpty ||
        fcm == null ||
        fcm.isEmpty) {
      return;
    }

    try {
      await authRepository.disablePushNotifications(
        accessToken: accessToken,
        fcmToken: fcm,
      );
    } catch (_) {
      // Si falla el backend, igual dejamos desactivado en la app.
    }
  }

  /// Token JWT vigente para APIs protegidas (memoria o almacenamiento).
  Future<String?> resolveAccessToken() async {
    final inMemory = state.user?.token;
    if (inMemory != null &&
        inMemory.isNotEmpty &&
        isAccessTokenValid(inMemory)) {
      return inMemory;
    }

    final stored = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    if (stored != null && stored.isNotEmpty && isAccessTokenValid(stored)) {
      return stored;
    }
    return null;
  }

  Future<void> logoutUser({
    String? errorMessage,
    int? onlyIfGeneration,
  }) async {
    if (onlyIfGeneration != null && _sessionGeneration != onlyIfGeneration) {
      return;
    }
    _sessionGeneration++;
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
    FcmTokenRegistry.clear();
    _registeredFcmToken = null;

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
