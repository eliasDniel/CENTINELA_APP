import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/infrastructure.dart';
import 'services/key_value_storage_impl.dart';

final authRepositoryProvider = Provider((ref) {
  final keyValueStorageService = KeyValueStorageImpl();
  return AuthRepositoryImpl(
    dataSources: AuthDataSourceImpl(
      keyValueStorageService: keyValueStorageService,
    ),
  );
});
