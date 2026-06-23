import 'dart:isolate';

import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/auth/domain/repositories/auth_repositories.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import '../widgets/widgets.dart';

// register_form_provider.dart
class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isRegistered;
  final String errorMessage;
  final Alias alias;
  final Email email;
  final Phone phone;
  final Password password;
  final Zona zona;
  final List<ZonaEntity> zonas;

  RegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.isRegistered = false,
    this.errorMessage = '',
    this.alias = const Alias.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phone = const Phone.pure(),
    this.zona = const Zona.pure(),
    this.zonas = const <ZonaEntity>[],
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isRegistered,
    String? errorMessage,
    Alias? alias,
    Email? email,
    Phone? phone,
    Password? password,
    Zona? zona,
    List<ZonaEntity>? zonas,
  }) {
    return RegisterFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      isRegistered: isRegistered ?? this.isRegistered,
      errorMessage: errorMessage ?? this.errorMessage,
      alias: alias ?? this.alias,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      zona: zona ?? this.zona,
      zonas: zonas ?? this.zonas,
    );
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Future<String?> Function({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  })
  registerFormCallback;
  final AuthRepository authRepository;

  RegisterFormNotifier({
    required this.registerFormCallback,
    required this.authRepository,
  }) : super(RegisterFormState());

  void onAliasChanged(String value) {
    final alias = Alias.dirty(value);
    state = state.copyWith(
      alias: alias,
      isValid: Formz.validate([alias, state.email, state.password, state.zona]),
    );
  }

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password, state.alias, state.zona]),
    );
  }

  void _resetForm() {
    final zonasActuales = state.zonas;
    state = RegisterFormState(
      zonas: zonasActuales,
    ); // <- esto ya pone alias, email, password, zona en .pure()
    state = state.copyWith(isRegistered: true);
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isValid: Formz.validate([password, state.email, state.alias, state.zona]),
    );
  }

  void onPhoneChanged(String value) {
    final phone = Phone.dirty(value);
    state = state.copyWith(
      phone: phone,
      // Solo bloquea el form si el teléfono tiene contenido Y es inválido
      isValid: value.isEmpty
          ? Formz.validate([
              state.email,
              state.alias,
              state.password,
              state.zona,
            ])
          : Formz.validate([
              phone,
              state.email,
              state.alias,
              state.password,
              state.zona,
            ]),
    );
  }

  void onZonaChanged(String value) {
    final zona = Zona.dirty(value);
    state = state.copyWith(
      zona: zona,
      isValid: Formz.validate([zona, state.email, state.alias, state.password]),
    );
  }

  void onSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;

    state = state.copyWith(isPosting: true, errorMessage: '');

    final errorMessage = await registerFormCallback(
      email: state.email.value,
      password: state.password.value,
      alias: state.alias.value,
      phone: state.phone.value.isEmpty ? null : state.phone.value,
      zonaId: state.zona.value,
    );

    final isSuccess = errorMessage == null;

    if (isSuccess) {
      _resetForm();
    }

    state = state.copyWith(
      isPosting: false,
      isRegistered: isSuccess,
      errorMessage: errorMessage ?? '',
    );
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final alias = Alias.dirty(state.alias.value);
    final zona = Zona.dirty(state.zona.value);
    final phone = Phone.dirty(state.phone.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      alias: alias,
      zona: zona,
      phone: phone,
      isValid: state.phone.value.isEmpty
          ? Formz.validate([email, password, alias, zona])
          : Formz.validate([email, password, alias, zona, phone]),
    );
  }

  Future<void> loadZonas() async {
    final result = await authRepository.getZonas();
    state = state.copyWith(zonas: result);
  }
}

final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((
      ref,
    ) {
      final authRepository = ref.watch(authRepositoryProvider);
      return RegisterFormNotifier(
        registerFormCallback: ref.watch(authProvider.notifier).registerUser,
        authRepository: authRepository,
      );
    });
