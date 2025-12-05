import 'package:flutter_test/flutter_test.dart';
import 'package:studify/data/models/schedule_repeat_model.dart';

void main() {
  group('ScheduleRepeat Model Tests', () {
    test('displayText returns "Tidak berulang" when daysOfWeek is empty', () {
      final repeat = ScheduleRepeat(daysOfWeek: []);
      expect(repeat.displayText, 'Tidak berulang');
    });

    test('displayText returns "Setiap hari" when all 7 days are selected', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1, 2, 3, 4, 5, 6, 7]);
      expect(repeat.displayText, 'Setiap hari');
    });

    test(
      'displayText returns "Setiap hari kerja" when Mon-Fri are selected',
      () {
        final repeat = ScheduleRepeat(daysOfWeek: [1, 2, 3, 4, 5]);
        expect(repeat.displayText, 'Setiap hari kerja');
      },
    );

    test('displayText returns specific days when random days are selected', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1, 3, 5]); // Mon, Wed, Fri
      expect(repeat.displayText, 'Senin, Rabu, Jumat');
    });

    test('displayText includes repeat count if greater than 1', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1], repeatCount: 16);
      expect(repeat.displayText, 'Senin (16x)');
    });

    test('displayText does NOT include repeat count if it is 1', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1], repeatCount: 1);
      expect(repeat.displayText, 'Senin');
    });

    test('displayText combines complex days with repeat count', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1, 3], repeatCount: 5);
      expect(repeat.displayText, 'Senin, Rabu (5x)');
    });

    test('copyWith works correctly', () {
      final repeat = ScheduleRepeat(daysOfWeek: [1], repeatCount: 1);
      final newRepeat = repeat.copyWith(repeatCount: 10);

      expect(newRepeat.daysOfWeek, [1]);
      expect(newRepeat.repeatCount, 10);
    });
  });
}
