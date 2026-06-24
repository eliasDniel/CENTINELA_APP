import 'package:centinela_milagro/features/auth/infrastructure/models/check_status.dart';

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
  static UserEntity fromCheckStatus(CheckStatusResponse checkStatusResponse) {
    return UserEntity(
      uuid: checkStatusResponse.user.id,
      email: checkStatusResponse.user.email,
      rol: checkStatusResponse.user.rol,
      token: checkStatusResponse.accessToken,
      refreshToken: checkStatusResponse.refreshToken,
      zonaId: checkStatusResponse.zonaPrincipalId,
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
