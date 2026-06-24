import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/services/key_value_storage_impl.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../infrastructure/datasources/report_datasource_impl.dart';
import '../../infrastructure/repositories/reports_repository_impl.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
    final keyValueStorageService = KeyValueStorageImpl();
  return ReportsRepositoryImpl(datasources: ReportDatasourceImpl(keyValueStorageService: keyValueStorageService));
});
