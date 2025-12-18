import 'package:studify/data/models/combined_schedule_model.dart';
import 'package:studify/data/services/combined_schedule_service.dart';

class FakeCombinedScheduleService implements CombinedScheduleService {
  @override
  Future<CombinedScheduleResponse> getCombinedSchedules({
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return CombinedScheduleResponse(
      data: [],
      meta: CombinedScheduleMeta(
        availableSources: [],
        currentFilter: source,
        total: 0,
      ),
    );
  }
}
