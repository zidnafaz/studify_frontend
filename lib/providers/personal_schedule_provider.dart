import 'package:flutter/foundation.dart';
import '../data/models/personal_schedule_model.dart';
import '../data/services/personal_schedule_service.dart';
import '../core/errors/api_exception.dart';

class PersonalScheduleProvider with ChangeNotifier {
  final PersonalScheduleService _personalScheduleService = PersonalScheduleService();

  List<PersonalSchedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // public getters
  List<PersonalSchedule> get schedules => List.unmodifiable(_schedules);
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

  Future<void> fetchPersonalSchedules() async {
    await _withLoading(() async {
      final result = await _personalScheduleService.getPersonalSchedules();
      _schedules = result;
      _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      return result;
    });
  }

  Future<PersonalSchedule> createPersonalSchedule({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    return await _withLoading(() async {
      final schedule = await _personalScheduleService.createPersonalSchedule(
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        color: color,
      );
      _schedules = List.from(_schedules)..add(schedule);
      _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      return schedule;
    });
  }

  Future<PersonalSchedule> updatePersonalSchedule({
    required int scheduleId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    String? color,
  }) async {
    return await _withLoading(() async {
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
      return schedule;
    });
  }

  Future<void> deletePersonalSchedule(int scheduleId) async {
    await _withLoading(() async {
      await _personalScheduleService.deletePersonalSchedule(scheduleId);
      _schedules.removeWhere((s) => s.id == scheduleId);
      return true;
    });
  }
}

