import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/infrastructure.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(dataSources: AuthDataSourceImpl());
});
