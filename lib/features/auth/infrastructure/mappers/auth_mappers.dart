import '../../domain/domain.dart';
import '../../domain/entities/zona_entity.dart';
import '../infrastructure.dart';

class UserMappers {
  static UserEntity fromLoginAndZona({required LoginResponse loginResponse}) {
    return UserEntity(
      uuid: loginResponse.user.id,
      email: loginResponse.user.email,
      rol: loginResponse.user.rol,
      token: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
      zonaId: loginResponse.zonaPrincipalId,
    );
  }

  // Para checkStatus cuando el backend ya te devuelva todo junto
  static UserEntity fromCheckStatus(Map<String, dynamic> json) {
    return UserEntity(
      uuid: json['id'],
      email: json['email'],
      rol: json['rol'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      zonaId: json['zonaId'],
    );
  }

  static ZonaEntity fromResponseToEntity(Map<dynamic, dynamic> zona) {
    return ZonaEntity(
      id: zona['id'],
      nombre: zona['nombre'],
      descripcion: zona['descripcion'],
      riesgoNivel: zona['riesgoNivel'],
    );
  }
}
