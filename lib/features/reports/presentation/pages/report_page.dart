// RF-0303: Report page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/report_form.dart';

class ReportPage extends ConsumerWidget {
  static const String routeName = 'report/new';

  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte'), centerTitle: true),
      body: const ReportForm(),
    );
  }
}
