int getNotificationId(String taskId, int reminderIndex) {
  return (taskId.hashCode.abs() * 100 + reminderIndex) & 0x7FFFFFFF;
}

DateTime? calculateReminderTime(String reminder, DateTime dueDateTime) {
  final now = DateTime.now();

  switch (reminder) {
    case '1 day before':
      final t = dueDateTime.subtract(const Duration(days: 1));
      return t.isAfter(now) ? t : null;
    case '12 hours before':
      final t = dueDateTime.subtract(const Duration(hours: 12));
      return t.isAfter(now) ? t : null;
    case '4 hours before':
      final t = dueDateTime.subtract(const Duration(hours: 4));
      return t.isAfter(now) ? t : null;
    case '2 hours before':
      final t = dueDateTime.subtract(const Duration(hours: 2));
      return t.isAfter(now) ? t : null;
    case '1 hour before':
      final t = dueDateTime.subtract(const Duration(hours: 1));
      return t.isAfter(now) ? t : null;
    case '30 minutes before':
      final t = dueDateTime.subtract(const Duration(minutes: 30));
      return t.isAfter(now) ? t : null;
    case '15 minutes before':
      final t = dueDateTime.subtract(const Duration(minutes: 15));
      return t.isAfter(now) ? t : null;
    case '10 minutes before':
      final t = dueDateTime.subtract(const Duration(minutes: 10));
      return t.isAfter(now) ? t : null;
    case '5 minutes before':
      final t = dueDateTime.subtract(const Duration(minutes: 5));
      return t.isAfter(now) ? t : null;
    case 'at due time':
      return dueDateTime.isAfter(now) ? dueDateTime : null;
    case 'none':
    default:
      return null;
  }
}
