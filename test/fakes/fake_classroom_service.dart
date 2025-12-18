import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/user_model.dart';
import 'package:studify/data/services/classroom_service.dart';
import 'package:studify/data/services/class_schedule_service.dart';
import 'package:studify/data/models/class_schedule_model.dart';

class FakeClassroomService implements ClassroomService {
  final List<Classroom> _classrooms = [];
  final List<ClassSchedule> _schedules = []; // Store schedules to return them

  @override
  Future<List<Classroom>> getClassrooms() async {
    return _classrooms;
  }

  @override
  Future<Classroom> createClassroom({
    required String name,
    String? description,
  }) async {
    final newClassroom = Classroom(
      id: _classrooms.length + 1,
      name: name,
      description: description ?? '',
      uniqueCode: 'FAKE-${_classrooms.length + 1}',
      ownerId: 1,
      createdAt: DateTime.now(), // Model expects DateTime directly?
      // Checking Model... Step 199 says:
      // final DateTime createdAt;
      // final DateTime updatedAt;
      // But Step 205 (Lines 31,32) passed .toIso8601String().
      // WAIT. Step 199: @JsonKey(name: 'created_at') final DateTime createdAt;
      // This means the field is DateTime. JSON conversion handles string.
      // So passed value MUST be DateTime.
      // My Previous step 205 showed .toIso8601String(). This IS AN ERROR.
      // Model expects DateTime.
      updatedAt: DateTime.now(),
      users: [User(id: 1, name: 'Test User', email: 'test@example.com')],
    );
    _classrooms.add(newClassroom);
    return newClassroom;
  }

  @override
  Future<Classroom> joinClassroom(String uniqueCode) async {
    try {
      final existing = _classrooms.firstWhere(
        (c) => c.uniqueCode == uniqueCode,
      );

      // Simulate adding the current user (Student Bob, ID 2)
      // ideally we would get this from AuthService, but for this fake/test structure:
      final newUser = User(
        id: 2,
        name: 'Student Bob',
        email: 'bob@example.com',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updatedUsers = List<User>.from(existing.users ?? [])..add(newUser);

      final updatedClassroom = Classroom(
        id: existing.id,
        name: existing.name,
        description: existing.description,
        uniqueCode: existing.uniqueCode,
        ownerId: existing.ownerId,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        users: updatedUsers,
        owner: existing.owner,
      );

      final index = _classrooms.indexOf(existing);
      _classrooms[index] = updatedClassroom;

      return updatedClassroom;
    } catch (e) {
      throw Exception('Classroom not found for code: $uniqueCode');
    }
  }

  @override
  Future<Classroom> getClassroom(int classroomId) async {
    return _classrooms.firstWhere(
      (c) => c.id == classroomId,
      orElse: () => throw Exception('Classroom not found'),
    );
  }

  @override
  Future<void> deleteClassroom(int id) async {
    _classrooms.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> removeMember({
    required int classroomId,
    required int userId,
  }) async {}

  @override
  Future<void> transferOwnership({
    required int classroomId,
    required int newOwnerId,
  }) async {}

  @override
  Future<Classroom> updateClassroomDescription({
    required int classroomId,
    String? description,
  }) async {
    final index = _classrooms.indexWhere((c) => c.id == classroomId);
    if (index == -1) throw Exception('Not found');
    return _classrooms[index];
  }

  @override
  Future<ClassSchedule> createClassSchedule({
    required int classroomId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? lecturer,
    String? description,
    String? color,
    int? coordinator1,
    int? coordinator2,
    List<int>? repeatDays,
    int? repeatCount,
    List<int>? reminders,
  }) async {
    final schedule = ClassSchedule(
      id: _schedules.length + 1,
      classroomId: classroomId,
      title: title,
      startTime: startTime, // Pass DateTime directly
      endTime: endTime, // Pass DateTime directly
      createdAt: DateTime.now(), // Pass DateTime
      updatedAt: DateTime.now(), // Pass DateTime
      color: color ?? '#000000',
      description: description,
      location: location,
      lecturer: lecturer,
      coordinator1: coordinator1,
      coordinator2: coordinator2,
    );
    _schedules.add(schedule);
    return schedule;
  }

  @override
  Future<void> deleteClassSchedule({
    required int classroomId,
    required int scheduleId,
  }) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
  }

  @override
  Future<List<ClassSchedule>> getClassSchedules(
    int classroomId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _schedules.where((s) => s.classroomId == classroomId).toList();
  }

  @override
  Future<void> leaveClassroom(int classroomId) async {}

  @override
  Future<ClassSchedule> updateClassSchedule({
    required int classroomId,
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? lecturer,
    String? description,
    String? color,
    int? coordinator1,
    int? coordinator2,
    List<int>? reminders,
  }) async {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index == -1) throw Exception('Schedule not found');

    var s = _schedules[index];
    // Create new instance with updates (ClassSchedule is likely immutable)
    // NOTE: ClassSchedule doesn't have copyWith in the snippet, so I'll reconstruct it.
    final updated = ClassSchedule(
      id: s.id,
      classroomId: s.classroomId,
      title: title ?? s.title,
      startTime: startTime ?? s.startTime,
      endTime: endTime ?? s.endTime,
      location: location ?? s.location,
      lecturer: lecturer ?? s.lecturer,
      description: description ?? s.description,
      color: color ?? s.color,
      coordinator1: coordinator1 ?? s.coordinator1,
      coordinator2: coordinator2 ?? s.coordinator2,
      createdAt: s.createdAt,
      updatedAt: DateTime.now(),
    );
    _schedules[index] = updated;
    return updated;
  }
}

// Keeping this matching the request, but it seems redundant if we use ClassroomService mostly.
// However, the provider might depend on ClassScheduleService separately.
class FakeClassScheduleService implements ClassScheduleService {
  @override
  Future<List<ClassSchedule>> getClassSchedules(int classroomId) async {
    return [];
  }

  @override
  Future<ClassSchedule> createClassSchedule(
    int classroomId,
    Map<String, dynamic> data,
  ) async {
    // Assuming data contains DateTime objects or Strings that need parsing?
    // In actual service, it likely receives a Map from a form.
    // For test stability, let's assume we parse them if they are strings, or cast if they are DateTimes.

    DateTime start;
    if (data['start_time'] is String) {
      start = DateTime.parse(data['start_time']);
    } else {
      start = data['start_time'];
    }

    DateTime end;
    if (data['end_time'] is String) {
      end = DateTime.parse(data['end_time']);
    } else {
      end = data['end_time'];
    }

    return ClassSchedule(
      id: 999,
      classroomId: classroomId,
      title: data['title'],
      startTime: start,
      endTime: end,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: data['color'] ?? '#000000',
    );
  }

  @override
  Future<void> deleteClassSchedule(int classroomId, int scheduleId) async {}

  @override
  Future<ClassSchedule> updateClassSchedule(
    int classroomId,
    int scheduleId,
    Map<String, dynamic> data,
  ) async {
    return createClassSchedule(classroomId, data);
  }
}
