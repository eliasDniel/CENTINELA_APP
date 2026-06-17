import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import '../widgets/widgets.dart';

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final String errorMessage;
  final Email email;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.errorMessage = '',
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    String? errorMessage,
    Email? email,
    Password? password,
  }) {
    return LoginFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Future<bool> Function({required String email, required String password})
  loginFormCallback;

  LoginFormNotifier({required this.loginFormCallback})
    : super(LoginFormState());

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isValid: Formz.validate([password, state.email]),
    );
  }

  void onSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;

    state = state.copyWith(isPosting: true, errorMessage: '');

    final isSuccess = await loginFormCallback(
      email: state.email.value,
      password: state.password.value,
    );

    state = state.copyWith(
      isPosting: false,
      errorMessage: isSuccess ? '' : 'Credenciales inválidas',
    );
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isValid: Formz.validate([email, password]),
    );
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(
        loginFormCallback: ({required email, required password}) {
          return ref.watch(authProvider.notifier).loginUser(email, password);
        },
      );
    });
