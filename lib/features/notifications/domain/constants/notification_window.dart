const kNotificationWindowHours = 24;

bool isNotificationWithinWindow(DateTime timestamp, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final cutoff = reference.subtract(
    const Duration(hours: kNotificationWindowHours),
  );
  return !timestamp.isBefore(cutoff);
}
