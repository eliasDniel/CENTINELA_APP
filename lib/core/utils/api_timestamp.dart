/// Convierte `timestamp` del API a milisegundos Unix.
int parseApiTimestamp(dynamic value, {int? fallbackMs}) {
  if (value is int) {
    return value < 10000000000 ? value * 1000 : value;
  }
  if (value is num) {
    return parseApiTimestamp(value.toInt(), fallbackMs: fallbackMs);
  }
  if (value is String) {
    final asInt = int.tryParse(value);
    if (asInt != null) {
      return parseApiTimestamp(asInt, fallbackMs: fallbackMs);
    }
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.millisecondsSinceEpoch;
  }
  if (value is DateTime) return value.millisecondsSinceEpoch;
  return fallbackMs ?? DateTime.now().millisecondsSinceEpoch;
}

DateTime apiTimestampToDateTime(int timestampMs) {
  return DateTime.fromMillisecondsSinceEpoch(timestampMs, isUtc: true).toLocal();
}
