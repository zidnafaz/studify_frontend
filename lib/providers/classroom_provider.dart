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

  List<Classroom> get classrooms => _classrooms;
  Classroom? get selectedClassroom => _selectedClassroom;
  List<ClassSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all classrooms
  Future<void> fetchClassrooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classrooms = await _classroomService.getClassrooms();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get classroom by ID
  Future<void> fetchClassroom(int classroomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedClassroom = await _classroomService.getClassroom(classroomId);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create classroom
  Future<Classroom> createClassroom({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final classroom = await _classroomService.createClassroom(
        name: name,
        description: description,
      );
      _classrooms.add(classroom);
      _isLoading = false;
      notifyListeners();
      return classroom;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Join classroom
  Future<Classroom> joinClassroom(String uniqueCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final classroom = await _classroomService.joinClassroom(uniqueCode);
      _classrooms.add(classroom);
      _isLoading = false;
      notifyListeners();
      return classroom;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get schedules for a classroom
  Future<void> fetchClassSchedules(int classroomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules = await _classroomService.getClassSchedules(classroomId);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create schedule
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
      
      // Refresh schedules to get all created schedules (in case of repeating)
      await fetchClassSchedules(classroomId);
      
      _isLoading = false;
      notifyListeners();
      return schedule;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update schedule
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
      
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[index] = schedule;
      }
      
      _isLoading = false;
      notifyListeners();
      return schedule;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete schedule
  Future<void> deleteClassSchedule({
    required int classroomId,
    required int scheduleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _classroomService.deleteClassSchedule(
        classroomId: classroomId,
        scheduleId: scheduleId,
      );
      
      _schedules.removeWhere((s) => s.id == scheduleId);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Leave classroom
  Future<void> leaveClassroom(int classroomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _classroomService.leaveClassroom(classroomId);
      
      _classrooms.removeWhere((c) => c.id == classroomId);
      if (_selectedClassroom?.id == classroomId) {
        _selectedClassroom = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Remove member
  Future<void> removeMember({
    required int classroomId,
    required int userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _classroomService.removeMember(
        classroomId: classroomId,
        userId: userId,
      );
      
      // Refresh classroom data to get updated members list
      await fetchClassroom(classroomId);
      
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Transfer ownership
  Future<void> transferOwnership({
    required int classroomId,
    required int newOwnerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _classroomService.transferOwnership(
        classroomId: classroomId,
        newOwnerId: newOwnerId,
      );
      
      // Refresh classroom data to get updated owner info
      await fetchClassroom(classroomId);
      
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update classroom description
  Future<void> updateClassroomDescription({
    required int classroomId,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedClassroom = await _classroomService.updateClassroomDescription(
        classroomId: classroomId,
        description: description,
      );
      
      // Update in list
      final index = _classrooms.indexWhere((c) => c.id == classroomId);
      if (index != -1) {
        _classrooms[index] = updatedClassroom;
      }
      
      // Update selected classroom if it's the same
      if (_selectedClassroom?.id == classroomId) {
        _selectedClassroom = updatedClassroom;
      }
      
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSchedules() {
    _schedules = [];
    notifyListeners();
  }
}
