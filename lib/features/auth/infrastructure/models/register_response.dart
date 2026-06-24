class RegisterResponse {
  final String email;
  final String nombre;
  final String tokenVerifEmail;
  final String message;

  RegisterResponse({
    required this.email,
    required this.nombre,
    required this.tokenVerifEmail,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        email: json["email"],
        nombre: json["nombre"],
        tokenVerifEmail: json["tokenVerifEmail"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "email": email,
    "nombre": nombre,
    "tokenVerifEmail": tokenVerifEmail,
    "message": message,
  };
}
