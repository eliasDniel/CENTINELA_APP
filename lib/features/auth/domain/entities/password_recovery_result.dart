class PasswordRecoveryResult {
  final String message;
  final String? resetToken;

  const PasswordRecoveryResult({
    required this.message,
    this.resetToken,
  });
}
