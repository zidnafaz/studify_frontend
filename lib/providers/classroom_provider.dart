import 'package:flutter/foundation.dart';
import '../data/models/classroom_model.dart';
import '../data/models/class_schedule_model.dart';
import '../data/services/classroom_service.dart';
import '../core/errors/api_exception.dart';

class ClassroomProvider with ChangeNotifier {
  final ClassroomService _classroomService = ClassroomService();

  List<Classroom> _classrooms = [];
  Classroom? _selectedClassroom;
  List<ClassSchedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // public getters
  List<Classroom> get classrooms => List.unmodifiable(_classrooms);
  Classroom? get selectedClassroom => _selectedClassroom;
  List<ClassSchedule> get schedules => List.unmodifiable(_schedules);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // -------------------------
  // PRIVATE HELPERS
  // -------------------------

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  /// Helper to execute an async operation with consistent loading + error handling.
  /// [operation] should perform changes to provider state but NOT call notifyListeners().
  /// notifyOnce: whether this wrapper should call notifyListeners at the end.
  Future<T> _withLoading<T>(
    Future<T> Function() operation, {
    bool notifyOnce = true,
  }) async {
    _setLoading(true);
    _setError(null);
    if (notifyOnce) notifyListeners();

    try {
      final res = await operation();
      return res;
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      rethrow;
    } finally {
      _setLoading(false);
      if (notifyOnce) notifyListeners();
    }
  }

  // -------------------------
  // API METHODS (safe)
  // -------------------------

  Future<void> fetchClassrooms() async {
    await _withLoading(() async {
      final result = await _classroomService.getClassrooms();
      // replace and notify once (via _withLoading finally)
      _classrooms = result;
      return result;
    });
  }

  /// Fetch single classroom and set _selectedClassroom.
  Future<void> fetchClassroom(int classroomId) async {
    await _withLoading(() async {
      final result = await _classroomService.getClassroom(classroomId);
      _selectedClassroom = result;
      return result;
    });
  }

  Future<Classroom> createClassroom({
    required String name,
    String? description,
  }) async {
    return await _withLoading(() async {
      final classroom = await _classroomService.createClassroom(
        name: name,
        description: description,
      );
      _classrooms = List.from(_classrooms)..add(classroom);
      return classroom;
    });
  }

  Future<Classroom> joinClassroom(String uniqueCode) async {
    return await _withLoading(() async {
      final classroom = await _classroomService.joinClassroom(uniqueCode);
      _classrooms = List.from(_classrooms)..add(classroom);
      return classroom;
    });
  }

  /// [notify] controls whether this call triggers notifyListeners().
  /// Use notify: false when calling internally then notify once at outer operation.
  Future<void> fetchClassSchedules(int classroomId, {bool notify = true}) async {
    // If notify == false, we manage loading/error without notify; otherwise use wrapper
    if (!notify) {
      try {
        final result = await _classroomService.getClassSchedules(classroomId);
        _schedules = result;
      } on ApiException catch (e) {
        _errorMessage = e.message;
        rethrow;
      } catch (e) {
        _errorMessage = 'Terjadi kesalahan: $e';
        rethrow;
      }
      return;
    }

    await _withLoading(() async {
      final result = await _classroomService.getClassSchedules(classroomId);
      _schedules = result;
      return result;
    });
  }

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
  }) async {
    return await _withLoading(() async {
      final schedule = await _classroomService.createClassSchedule(
        classroomId: classroomId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        lecturer: lecturer,
        description: description,
        color: color,
        coordinator1: coordinator1,
        coordinator2: coordinator2,
        repeatDays: repeatDays,
        repeatCount: repeatCount,
      );

      // Refresh schedules internally without firing notify twice.
      await fetchClassSchedules(classroomId, notify: false);

      // After internal refresh, we'll return to _withLoading which will notify once.
      return schedule;
    });
  }

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
  }) async {
    return await _withLoading(() async {
      final schedule = await _classroomService.updateClassSchedule(
        classroomId: classroomId,
        scheduleId: scheduleId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        lecturer: lecturer,
        description: description,
        color: color,
        coordinator1: coordinator1,
        coordinator2: coordinator2,
      );

      final idx = _schedules.indexWhere((s) => s.id == scheduleId);
      if (idx != -1) {
        _schedules[idx] = schedule;
      }

      return schedule;
    });
  }

  Future<void> deleteClassSchedule({
    required int classroomId,
    required int scheduleId,
  }) async {
    await _withLoading(() async {
      await _classroomService.deleteClassSchedule(
        classroomId: classroomId,
        scheduleId: scheduleId,
      );
      _schedules.removeWhere((s) => s.id == scheduleId);
      return true;
    });
  }

  Future<void> leaveClassroom(int classroomId) async {
    await _withLoading(() async {
      await _classroomService.leaveClassroom(classroomId);
      _classrooms.removeWhere((c) => c.id == classroomId);
      if (_selectedClassroom?.id == classroomId) {
        _selectedClassroom = null;
      }
      return true;
    });
  }

  Future<void> removeMember({
    required int classroomId,
    required int userId,
  }) async {
    await _withLoading(() async {
      await _classroomService.removeMember(
        classroomId: classroomId,
        userId: userId,
      );

      // refresh classroom data but avoid double-notify: use notify: false
      await fetchClassroom(classroomId);
      await fetchClassSchedules(classroomId, notify: false);
      return true;
    });
  }

  Future<void> transferOwnership({
    required int classroomId,
    required int newOwnerId,
  }) async {
    await _withLoading(() async {
      await _classroomService.transferOwnership(
        classroomId: classroomId,
        newOwnerId: newOwnerId,
      );

      // refresh detail
      await fetchClassroom(classroomId);
      return true;
    });
  }

  Future<void> updateClassroomDescription({
    required int classroomId,
    String? description,
  }) async {
    await _withLoading(() async {
      final updatedClassroom = await _classroomService.updateClassroomDescription(
        classroomId: classroomId,
        description: description,
      );

      final idx = _classrooms.indexWhere((c) => c.id == classroomId);
      if (idx != -1) _classrooms[idx] = updatedClassroom;

      if (_selectedClassroom?.id == classroomId) {
        _selectedClassroom = updatedClassroom;
      }

      return updatedClassroom;
    });
  }

  void clearError() {
    _setError(null);
    notifyListeners();
  }

  void clearSchedules() {
    _schedules = [];
    notifyListeners();
  }
}
