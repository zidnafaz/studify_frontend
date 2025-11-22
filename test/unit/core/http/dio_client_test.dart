import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/core/http/dio_client.dart';
import 'package:studify/core/errors/api_exception.dart';
import 'package:studify/data/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DioClient Tests', () {
    late DioClient dioClient;
    late DioAdapter dioAdapter;
    late AuthService authService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
      dioClient = DioClient();
      
      // Create DioAdapter for mocking
      dioAdapter = DioAdapter(dio: dioClient.dio);
    });

    tearDown(() {
      dioAdapter.close();
    });

    group('Basic HTTP Methods', () {
      test('should handle GET request successfully', () async {
        // Arrange
        dioAdapter.onGet(
          '/api/test',
          (server) => server.reply(200, {'data': 'get success'}),
        );

        // Act
        final response = await dioClient.get('/api/test');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['data'], 'get success');
      });

      test('should handle POST request successfully', () async {
        // Arrange
        dioAdapter.onPost(
          '/api/test',
          (server) => server.reply(201, {'data': 'post success'}),
          data: {'name': 'test'},
        );

        // Act
        final response = await dioClient.post(
          '/api/test',
          data: {'name': 'test'},
        );

        // Assert
        expect(response.statusCode, 201);
        expect(response.data['data'], 'post success');
      });

      test('should handle PUT request successfully', () async {
        // Arrange
        dioAdapter.onPut(
          '/api/test/1',
          (server) => server.reply(200, {'data': 'put success'}),
          data: {'name': 'updated'},
        );

        // Act
        final response = await dioClient.put(
          '/api/test/1',
          data: {'name': 'updated'},
        );

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['data'], 'put success');
      });

      test('should handle DELETE request successfully', () async {
        // Arrange
        dioAdapter.onDelete(
          '/api/test/1',
          (server) => server.reply(200, {'message': 'deleted'}),
        );

        // Act
        final response = await dioClient.delete('/api/test/1');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['message'], 'deleted');
      });
    });

    group('Token Management', () {
      test('should make request when token exists', () async {
        // Arrange
        const testToken = 'test_token_123';
        await authService.saveToken(testToken);

        dioAdapter.onGet(
          '/api/test',
          (server) => server.reply(200, {'data': 'success'}),
        );

        // Act
        final response = await dioClient.get('/api/test');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['data'], 'success');
      });

      test('should work without token when token is null', () async {
        // Arrange
        await authService.clearAuthData();

        dioAdapter.onGet(
          '/api/test',
          (server) => server.reply(200, {'data': 'success'}),
        );

        // Act
        final response = await dioClient.get('/api/test');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['data'], 'success');
      });
    });

    group('Error Handling', () {
      test('should throw UnauthorizedException on 401', () async {
        // Arrange
        dioAdapter.onGet(
          '/api/auth/login',
          (server) => server.reply(401, {'message': 'Unauthorized'}),
        );

        // Act & Assert
        expect(
          () => dioClient.get('/api/auth/login'),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw NotFoundException on 404', () async {
        // Arrange
        dioAdapter.onGet(
          '/api/notfound',
          (server) => server.reply(404, {'message': 'Not found'}),
        );

        // Act & Assert
        expect(
          () => dioClient.get('/api/notfound'),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('should throw ForbiddenException on 403', () async {
        // Arrange
        dioAdapter.onGet(
          '/api/forbidden',
          (server) => server.reply(403, {'message': 'Forbidden'}),
        );

        // Act & Assert
        expect(
          () => dioClient.get('/api/forbidden'),
          throwsA(isA<ForbiddenException>()),
        );
      });

      test('should throw ApiException on 400', () async {
        // Arrange
        dioAdapter.onGet(
          '/api/badrequest',
          (server) => server.reply(400, {'message': 'Bad request'}),
        );

        // Act & Assert
        expect(
          () => dioClient.get('/api/badrequest'),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
