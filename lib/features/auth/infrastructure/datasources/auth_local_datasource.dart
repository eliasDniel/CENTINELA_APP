// RF-0301, RF-0302: Mock local auth data source
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  // In-memory storage of users
  final Map<String, UserModel> _users = {};

  Future<UserModel> login(String alias, String password) async {
    // Mock: any non-empty alias+password combination works
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find user by alias (simplified: we just check if someone with this alias ever logged in)
    if (_users.containsKey(alias)) {
      return _users[alias]!;
    }

    // Create and return mock user if it's their first login
    final user = UserModel(
      alias: alias,
      uuid: const Uuid().v4(),
      barrio: 'Norte', // Default barrio for login
      phone: null,
      isVisitor: false,
    );
    _users[alias] = user;
    return user;
  }

  Future<UserModel> register(
    String alias,
    String password,
    String barrio, {
    String? phone,
  }) async {
    // Mock: Generate UUID v4 for new user
    await Future.delayed(const Duration(milliseconds: 500));

    final uuid = const Uuid().v4();
    final user = UserModel(
      alias: alias,
      uuid: uuid,
      barrio: barrio,
      phone: phone,
      isVisitor: false,
    );
    _users[alias] = user;
    return user;
  }

  Future<UserModel> loginAsVisitor() async {
    // Mock: Generate a visitor session
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      alias: 'Visitante_${DateTime.now().millisecondsSinceEpoch}',
      uuid: const Uuid().v4(),
      barrio: 'Centro',
      phone: null,
      isVisitor: true,
    );
  }
}
