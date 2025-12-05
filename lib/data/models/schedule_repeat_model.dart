class ScheduleRepeat {
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final int repeatCount;

  ScheduleRepeat({required this.daysOfWeek, this.repeatCount = 1});

  bool get hasRepeat => daysOfWeek.isNotEmpty;

  String get displayText {
    if (daysOfWeek.isEmpty) return 'Tidak berulang';

    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final selectedDays = daysOfWeek.map((day) => dayNames[day - 1]).toList();

    String text;
    if (daysOfWeek.length == 7) {
      text = 'Setiap hari';
    } else if (daysOfWeek.length == 5 &&
        daysOfWeek.every((day) => day >= 1 && day <= 5)) {
      text = 'Setiap hari kerja';
    } else {
      text = selectedDays.join(', ');
    }

    if (repeatCount > 1) {
      text += ' (${repeatCount}x)';
    }

    return text;
  }

  ScheduleRepeat copyWith({List<int>? daysOfWeek, int? repeatCount}) {
    return ScheduleRepeat(
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }
}
