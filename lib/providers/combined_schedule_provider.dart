import 'package:flutter/foundation.dart';
import '../data/models/combined_schedule_model.dart';
import '../data/services/combined_schedule_service.dart';
import '../core/errors/api_exception.dart';

class CombinedScheduleProvider with ChangeNotifier {
  final CombinedScheduleService _combinedScheduleService = CombinedScheduleService();

  List<CombinedSchedule> _schedules = [];
  List<ScheduleSource> _availableSources = [];
  String? _currentFilter;
  bool _isLoading = false;
  String? _errorMessage;

  List<CombinedSchedule> get schedules => _schedules;
  List<ScheduleSource> get availableSources => _availableSources;
  String? get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get combined schedules with optional source filter
  /// [source] can be: null (all), 'personal', or 'classroom:{id}'
  Future<void> fetchCombinedSchedules({String? source}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _combinedScheduleService.getCombinedSchedules(source: source);
      _schedules = response.data;
      _availableSources = response.meta.availableSources;
      _currentFilter = response.meta.currentFilter;
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

  /// Refresh schedules with current filter
  Future<void> refresh() async {
    await fetchCombinedSchedules(source: _currentFilter);
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

