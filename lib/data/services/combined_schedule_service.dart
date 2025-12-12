import '../../core/errors/api_exception.dart';
import '../../core/http/dio_client.dart';
import '../models/combined_schedule_model.dart';

class CombinedScheduleService {
  final DioClient _dioClient = DioClient();

  /// Get all combined schedules (personal + all classrooms)
  /// [source] can be:
  /// - null or 'all': Get all schedules
  /// - 'personal': Get only personal schedules
  /// - 'classroom:{id}': Get only schedules from specific classroom
  Future<CombinedScheduleResponse> getCombinedSchedules({
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print(
        '🔵 Get combined schedules request${source != null ? " (source: $source)" : ""}',
      );

      final queryParams = <String, dynamic>{};
      if (source != null && source != 'all') {
        queryParams['source'] = source;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.get(
        '/api/schedules',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📡 Response status: ${response.statusCode}');
      // print('📄 Response body: ${response.data}'); // Commented out to avoid huge logs, enable if needed

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid response format: expected Map, got ${data.runtimeType}');
        }
        
        try {
          return CombinedScheduleResponse.fromJson(data);
        } catch (e, stack) {
          print('❌ JSON Parsing Error: $e');
          print('Stack trace: $stack');
          print('Problematic JSON data: $data');
          rethrow;
        }
      } else {
        throw ApiException(
          message: 'Failed to get combined schedules',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Get combined schedules error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
