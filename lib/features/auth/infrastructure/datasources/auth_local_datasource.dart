// RF-0301, RF-0302: Mock local auth data source
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final Map<String, UserModel> _users = {};

  Future<UserModel> login(String alias, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_users.containsKey(alias)) {
      return _users[alias]!;
    }

    final user = UserModel(
      alias: alias,
      uuid: const Uuid().v4(),
      zona: 'Milagro',
      barrio: 'Chirijos',
      phone: null,
      isVisitor: false,
    );
    _users[alias] = user;
    return user;
  }

  Future<UserModel> register(
    String alias,
    String password,
    String zona,
    String barrio, {
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final uuid = const Uuid().v4();
    final user = UserModel(
      alias: alias,
      uuid: uuid,
      zona: zona,
      barrio: barrio,
      phone: phone,
      isVisitor: false,
    );
    _users[alias] = user;
    return user;
  }

  Future<UserModel> updateLocation(
    String alias,
    String zona,
    String barrio,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final existing = _users[alias];
    if (existing == null) {
      throw Exception('Usuario no encontrado');
    }

    final updated = UserModel(
      alias: existing.alias,
      uuid: existing.uuid,
      zona: zona,
      barrio: barrio,
      phone: existing.phone,
      isVisitor: existing.isVisitor,
    );
    _users[alias] = updated;
    return updated;
  }

  Future<UserModel> loginAsVisitor() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      alias: 'Visitante_${DateTime.now().millisecondsSinceEpoch}',
      uuid: const Uuid().v4(),
      zona: 'Milagro',
      barrio: 'Chirijos',
      phone: null,
      isVisitor: true,
    );
  }
}
