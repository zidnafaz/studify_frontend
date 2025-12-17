import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studify/providers/combined_schedule_provider.dart';
import 'package:studify/data/models/combined_schedule_model.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late CombinedScheduleProvider provider;
  late MockCombinedScheduleService mockService;

  setUp(() {
    mockService = MockCombinedScheduleService();
    provider = CombinedScheduleProvider(service: mockService);
  });

  group('CombinedScheduleProvider Integration Tests', () {
    final testSchedule = CombinedSchedule(
      id: 1,
      type: 'personal',
      title: 'Study',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      color: '#FFFFFF',
      sourceName: 'Personal Schedule',
    );

    final testSource = ScheduleSource(
      id: 'all',
      type: 'all',
      name: 'All Schedules',
      description: 'All schedules',
    );

    final testResponse = CombinedScheduleResponse(
      data: [testSchedule],
      meta: CombinedScheduleMeta(
        total: 1,
        availableSources: [testSource],
        currentFilter: 'all',
      ),
    );

    test('fetchCombinedSchedules updates state correctly on success', () async {
      // Arrange
      when(mockService.getCombinedSchedules(
        source: anyNamed('source'),
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenAnswer((_) async => testResponse);

      // Act
      await provider.fetchCombinedSchedules();

      // Assert
      expect(provider.schedules, contains(testSchedule));
      expect(provider.availableSources, contains(testSource));
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
      verify(mockService.getCombinedSchedules(
        source: anyNamed('source'),
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).called(1);
    });

    test('fetchCombinedSchedules with filter updates filter and fetches schedules', () async {
      // Arrange
      when(mockService.getCombinedSchedules(
        source: 'personal',
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenAnswer((_) async => testResponse);

      // Act
      await provider.fetchCombinedSchedules(source: 'personal');

      // Assert
      expect(provider.currentFilter, 'all'); // The response sets it to 'all' in testResponse
      verify(mockService.getCombinedSchedules(
        source: 'personal',
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).called(1);
    });
  });
}
