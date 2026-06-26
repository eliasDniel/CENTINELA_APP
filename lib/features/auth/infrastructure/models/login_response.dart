class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final String message;
  final String zonaPrincipalId;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.message,
    required this.zonaPrincipalId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
    user: User.fromJson(json["user"]),
    message: json["message"] ?? '',
    zonaPrincipalId: json["zonaPrincipalId"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "user": user.toJson(),
    "message": message,
    "zonaPrincipalId": zonaPrincipalId,
  };
}

class User {
  final String id;
  final String alias;
  final String email;
  final String rol;

  User({required this.id, required this.alias, required this.email, required this.rol});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], alias: json["nombre"]?.toString() ?? '', email: json["email"], rol: json["rol"]);

  Map<String, dynamic> toJson() => {"id": id, "alias": alias, "email": email, "rol": rol};
}
