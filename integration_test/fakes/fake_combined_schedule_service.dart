import 'package:studify/data/models/combined_schedule_model.dart';
import 'package:studify/data/services/combined_schedule_service.dart';

class FakeCombinedScheduleService implements CombinedScheduleService {
  final List<CombinedSchedule> _schedules = [];

  void addSchedule(CombinedSchedule schedule) {
    _schedules.add(schedule);
  }

  @override
  Future<CombinedScheduleResponse> getCombinedSchedules({
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return CombinedScheduleResponse(
      data: _schedules,
      meta: CombinedScheduleMeta(
        availableSources: [
          ScheduleSource(
            id: 'all',
            type: 'all',
            name: 'All Schedules',
            description: 'Show all schedules',
          ),
          ScheduleSource(
            id: 'personal',
            type: 'personal',
            name: 'Personal Schedules',
            description: 'Show personal schedules',
          ),
        ],
        currentFilter: source,
        total: _schedules.length,
      ),
    );
  }
}
