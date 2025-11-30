import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:studify/core/http/dio_client.dart';
import 'package:studify/data/services/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ReminderService reminderService;
  late DioAdapter dioAdapter;
  late Dio dio;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    // Get the singleton DioClient instance
    final dioClient = DioClient();
    dio = dioClient.dio;

    // Create adapter and assign it to Dio
    dioAdapter = DioAdapter(dio: dio);

    reminderService = ReminderService();
  });

  group('ReminderService', () {
    test('createReminder sends correct request', () async {
      const remindableId = 1;
      const remindableType = 'class_schedule';
      const minutesBeforeStart = 15;

      dioAdapter.onPost(
        '/api/reminders',
        (server) => server.reply(201, {'message': 'Reminder created'}),
        data: {
          'remindable_id': remindableId,
          'remindable_type': remindableType,
          'minutes_before_start': minutesBeforeStart,
        },
      );

      await reminderService.createReminder(
        remindableId: remindableId,
        remindableType: remindableType,
        minutesBeforeStart: minutesBeforeStart,
      );
    });

    test('updateReminder sends correct request', () async {
      const reminderId = 1;
      const minutesBeforeStart = 30;

      dioAdapter.onPut(
        '/api/reminders/$reminderId',
        (server) => server.reply(200, {'message': 'Reminder updated'}),
        data: {'minutes_before_start': minutesBeforeStart},
      );

      await reminderService.updateReminder(
        reminderId: reminderId,
        minutesBeforeStart: minutesBeforeStart,
      );
    });

    test('deleteReminder sends correct request', () async {
      const reminderId = 1;

      dioAdapter.onDelete(
        '/api/reminders/$reminderId',
        (server) => server.reply(200, {'message': 'Reminder deleted'}),
      );

      await reminderService.deleteReminder(reminderId);
    });
  });
}
