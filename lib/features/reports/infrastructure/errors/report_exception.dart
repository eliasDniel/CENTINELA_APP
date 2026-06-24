class ReportException implements Exception {
  final String message;

  ReportException(this.message);

  @override
  String toString() => message;
}
