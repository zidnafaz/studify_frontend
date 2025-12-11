import 'package:flutter/foundation.dart';
import '../data/models/combined_schedule_model.dart';
import '../data/services/combined_schedule_service.dart';
import '../core/errors/api_exception.dart';

class CombinedScheduleProvider with ChangeNotifier {
  final CombinedScheduleService _combinedScheduleService =
      CombinedScheduleService();

  List<CombinedSchedule> _schedules = [];
  List<ScheduleSource> _availableSources = [];
  String? _currentFilter;
  bool _isLoading = false;
  String? _errorMessage;

  // public getters
  List<CombinedSchedule> get schedules => List.unmodifiable(_schedules);
  List<ScheduleSource> get availableSources =>
      List.unmodifiable(_availableSources);
  String? get currentFilter => _currentFilter;
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
      _setError('An error occurred: $e');
      rethrow;
    } finally {
      _setLoading(false);
      if (notifyOnce) notifyListeners();
    }
  }

  // -------------------------
  // API METHODS (safe)
  // -------------------------

  /// Get combined schedules with optional source filter
  /// [source] can be: null (all), 'personal', or 'classroom:{id}'
  Future<void> fetchCombinedSchedules({
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _withLoading(() async {
      final response = await _combinedScheduleService.getCombinedSchedules(
        source: source,
        startDate: startDate,
        endDate: endDate,
      );
      _schedules = response.data;
      _availableSources = response.meta.availableSources;
      _currentFilter = response.meta.currentFilter;
      return response;
    });
  }

  /// Refresh schedules with current filter
  Future<void> refresh({DateTime? startDate, DateTime? endDate}) async {
    await fetchCombinedSchedules(
      source: _currentFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear all data
  void clear() {
    _schedules = [];
    _availableSources = [];
    _currentFilter = null;
    _errorMessage = null;
    notifyListeners();
  }
}
