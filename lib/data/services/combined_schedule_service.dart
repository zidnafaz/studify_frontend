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
  Future<CombinedScheduleResponse> getCombinedSchedules({String? source}) async {
    try {
      print('🔵 Get combined schedules request${source != null ? " (source: $source)" : ""}');
      
      final queryParams = <String, dynamic>{};
      if (source != null && source != 'all') {
        queryParams['source'] = source;
      }

      final response = await _dioClient.get(
        '/api/schedules',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.data}');

      if (response.statusCode == 200) {
        return CombinedScheduleResponse.fromJson(response.data);
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

