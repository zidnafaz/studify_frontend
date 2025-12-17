import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/reminder_model.dart';

void main() {
  group('ReminderModel', () {
    final testDate = DateTime(2023, 1, 1, 12, 0, 0);
    final testJson = {
      'id': 1,
      'remindable_id': 101,
      'remindable_type': 'class_schedule',
      'minutes_before_start': 15,
      'status': 'active',
      'created_at': testDate.toIso8601String(),
      'updated_at': testDate.toIso8601String(),
    };

    test('fromJson creates a valid instance', () {
      final reminder = Reminder.fromJson(testJson);

      expect(reminder.id, 1);
      expect(reminder.remindableId, 101);
      expect(reminder.remindableType, 'class_schedule');
      expect(reminder.minutesBeforeStart, 15);
      expect(reminder.status, 'active');
      expect(reminder.createdAt, testDate);
      expect(reminder.updatedAt, testDate);
    });

    test('toJson creates a valid map', () {
      final reminder = Reminder(
        id: 1,
        remindableId: 101,
        remindableType: 'class_schedule',
        minutesBeforeStart: 15,
        status: 'active',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final json = reminder.toJson();

      expect(json['id'], 1);
      expect(json['remindable_id'], 101);
      expect(json['remindable_type'], 'class_schedule');
      expect(json['minutes_before_start'], 15);
      expect(json['status'], 'active');
      expect(json['created_at'], testDate.toIso8601String());
      expect(json['updated_at'], testDate.toIso8601String());
    });
  });
}
