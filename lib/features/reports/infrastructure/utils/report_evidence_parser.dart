import 'dart:convert';

/// Parsea `fotosUrls` del API (array JSON, string `"[]"`, o lista).
List<String> parseReportEvidenceUrls(dynamic value) {
  if (value == null) return [];

  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '[]') return [];

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {
      if (trimmed.startsWith('http')) return [trimmed];
    }
  }

  return [];
}
