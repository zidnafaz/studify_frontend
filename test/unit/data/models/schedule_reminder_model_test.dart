import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/schedule_reminder_model.dart';

void main() {
  group('ScheduleReminder', () {
    test('displayText returns correct string for minutes', () {
      final reminder = ScheduleReminder(minutesBefore: 15);
      expect(reminder.displayText, '15 Menit Sebelumnya');
    });

    test('displayText returns correct string for hours', () {
      final reminder = ScheduleReminder(minutesBefore: 60);
      expect(reminder.displayText, '1 Jam Sebelumnya');

      final reminder2 = ScheduleReminder(minutesBefore: 120);
      expect(reminder2.displayText, '2 Jam Sebelumnya');
    });

    test('displayText returns correct string for days', () {
      final reminder = ScheduleReminder(minutesBefore: 1440);
      expect(reminder.displayText, '1 Hari Sebelumnya');

      final reminder2 = ScheduleReminder(minutesBefore: 2880);
      expect(reminder2.displayText, '2 Hari Sebelumnya');
    });

    test('label returns correct string for minutes', () {
      final reminder = ScheduleReminder(minutesBefore: 30);
      expect(reminder.label, '30 Minutes Before');
    });

    test('label returns correct string for hours', () {
      final reminder = ScheduleReminder(minutesBefore: 60);
      expect(reminder.label, '1 Hour Before');

      final reminder2 = ScheduleReminder(minutesBefore: 180);
      expect(reminder2.label, '3 Hours Before');
    });

    test('label returns correct string for days', () {
      final reminder = ScheduleReminder(minutesBefore: 1440);
      expect(reminder.label, '1 Day Before');

      final reminder2 = ScheduleReminder(minutesBefore: 4320);
      expect(reminder2.label, '3 Days Before');
    });

    test('equality works correctly', () {
      final reminder1 = ScheduleReminder(minutesBefore: 15);
      final reminder2 = ScheduleReminder(minutesBefore: 15);
      final reminder3 = ScheduleReminder(minutesBefore: 30);

      expect(reminder1, equals(reminder2));
      expect(reminder1, isNot(equals(reminder3)));
    });
  });
}
