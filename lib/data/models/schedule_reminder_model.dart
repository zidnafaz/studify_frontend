class ScheduleReminder {
  final int minutesBefore;

  ScheduleReminder({
    required this.minutesBefore,
  });

  String get label {
    if (minutesBefore < 60) {
      return '$minutesBefore Minutes Before';
    } else if (minutesBefore < 1440) {
      final hours = minutesBefore ~/ 60;
      return '$hours ${hours == 1 ? 'Hour' : 'Hours'} Before';
    } else {
      final days = minutesBefore ~/ 1440;
      return '$days ${days == 1 ? 'Day' : 'Days'} Before';
    }
  }

  String get displayText {
    if (minutesBefore < 60) {
      return '$minutesBefore Menit Sebelumnya';
    } else if (minutesBefore < 1440) {
      final hours = minutesBefore ~/ 60;
      return '$hours Jam Sebelumnya';
    } else {
      final days = minutesBefore ~/ 1440;
      return '$days Hari Sebelumnya';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleReminder && other.minutesBefore == minutesBefore;
  }

  @override
  int get hashCode => minutesBefore.hashCode;
}
