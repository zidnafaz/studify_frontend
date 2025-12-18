import 'package:studify/data/models/personal_schedule_model.dart';
import 'package:studify/data/services/personal_schedule_service.dart';

class FakePersonalScheduleService implements PersonalScheduleService {
  final List<PersonalSchedule> _schedules = [];

  @override
  Future<List<PersonalSchedule>> getPersonalSchedules() async {
    return _schedules;
  }

  @override
  Future<PersonalSchedule> createPersonalSchedule({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? color, // Interface has nullable
    String? location,
    String? description,
    List<int>? reminders,
    List<int>? repeatDays,
    int? repeatCount,
  }) async {
    final newSchedule = PersonalSchedule(
      id: _schedules.length + 1,
      userId: 1, // Test User ID
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      color: color ?? '#000000', // Default if null
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _schedules.add(newSchedule);
    return newSchedule;
  }

  // Missing from interface but likely needed if provider calls it?
  // Checking provider: yes it calls getPersonalSchedules, create, update, delete.
  // Interface definition in previous view showed arguments for create/update.

  @override
  Future<PersonalSchedule> getPersonalSchedule(int id) async {
    return _schedules.firstWhere((s) => s.id == id);
  }

  @override
  Future<PersonalSchedule> updatePersonalSchedule({
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    String? color,
    List<int>? reminders,
  }) async {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      final old = _schedules[index];
      final updated = PersonalSchedule(
        id: old.id,
        userId: old.userId,
        title: title ?? old.title,
        startTime: startTime ?? old.startTime,
        endTime: endTime ?? old.endTime,
        location: location ?? old.location,
        description: description ?? old.description,
        color: color ?? old.color,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _schedules[index] = updated;
      return updated;
    }
    throw Exception('Schedule not found');
  }

  @override
  Future<void> deletePersonalSchedule(int id) async {
    _schedules.removeWhere((s) => s.id == id);
  }
}
