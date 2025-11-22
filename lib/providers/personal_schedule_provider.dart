import 'package:flutter/foundation.dart';
import '../data/models/personal_schedule_model.dart';
import '../data/services/personal_schedule_service.dart';
import '../core/errors/api_exception.dart';

class PersonalScheduleProvider with ChangeNotifier {
  final PersonalScheduleService _personalScheduleService = PersonalScheduleService();

  List<PersonalSchedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PersonalSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all personal schedules
  Future<void> fetchPersonalSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules = await _personalScheduleService.getPersonalSchedules();
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

  // Create personal schedule
  Future<PersonalSchedule> createPersonalSchedule({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final schedule = await _personalScheduleService.createPersonalSchedule(
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        color: color,
      );
      _schedules.add(schedule);
      _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
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

  // Update personal schedule
  Future<PersonalSchedule> updatePersonalSchedule({
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final schedule = await _personalScheduleService.updatePersonalSchedule(
        scheduleId: scheduleId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        color: color,
      );
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[index] = schedule;
        _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
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

  // Delete personal schedule
  Future<void> deletePersonalSchedule(int scheduleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _personalScheduleService.deletePersonalSchedule(scheduleId);
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
}

