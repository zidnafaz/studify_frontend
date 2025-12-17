import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:studify/providers/classroom_provider.dart';
import 'package:studify/data/services/classroom_service.dart';
import 'package:studify/data/models/classroom_model.dart';
import 'package:studify/data/models/user_model.dart';

import 'classroom_flow_test.mocks.dart';

@GenerateMocks([ClassroomService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Classroom Flow Integration Tests', () {
    late ClassroomProvider provider;
    late MockClassroomService mockService;

    setUp(() {
      mockService = MockClassroomService();
      provider = ClassroomProvider(service: mockService);
    });

    test('Complete classroom creation flow', () async {
      // Arrange
      final classroomData = {
        'name': 'Math Class',
        'description': 'Advanced Mathematics',
      };

      final owner = User(
        id: 1,
        name: 'Teacher',
        email: 'teacher@example.com',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final createdClassroom = Classroom(
        id: 1,
        ownerId: owner.id,
        name: classroomData['name']!,
        uniqueCode: 'ABC123',
        description: classroomData['description'],
        owner: owner,
        users: [owner],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockService.createClassroom(
        name: anyNamed('name'),
        description: anyNamed('description'),
      )).thenAnswer((_) async => createdClassroom);

      // Act
      await provider.createClassroom(
        name: classroomData['name']!,
        description: classroomData['description'],
      );

      // Assert
      expect(provider.classrooms, contains(createdClassroom));
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
      verify(mockService.createClassroom(
        name: classroomData['name']!,
        description: classroomData['description'],
      )).called(1);
    });

    test('Complete join classroom flow', () async {
      // Arrange
      final uniqueCode = 'ABC123';
      final classroom = Classroom(
        id: 1,
        ownerId: 2,
        name: 'Math Class',
        uniqueCode: uniqueCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockService.joinClassroom(uniqueCode))
          .thenAnswer((_) async => classroom);
      
      // Act
      await provider.joinClassroom(uniqueCode);

      // Assert
      expect(provider.classrooms, contains(classroom));
      verify(mockService.joinClassroom(uniqueCode)).called(1);
    });

    test('Complete leave classroom flow', () async {
      // Arrange
      final classroom = Classroom(
        id: 1,
        ownerId: 2,
        name: 'Math Class',
        uniqueCode: 'ABC123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Populate provider with classroom
      when(mockService.getClassrooms()).thenAnswer((_) async => [classroom]);
      await provider.fetchClassrooms();

      when(mockService.leaveClassroom(classroom.id))
          .thenAnswer((_) async => {});

      // Act
      await provider.leaveClassroom(classroom.id);

      // Assert
      expect(provider.classrooms, isEmpty);
      verify(mockService.leaveClassroom(classroom.id)).called(1);
    });

    test('Complete delete classroom flow (owner only)', () async {
      // Arrange
      final classroom = Classroom(
        id: 1,
        ownerId: 1,
        name: 'Math Class',
        uniqueCode: 'ABC123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Populate provider with classroom
      when(mockService.getClassrooms()).thenAnswer((_) async => [classroom]);
      await provider.fetchClassrooms();

      when(mockService.deleteClassroom(classroom.id))
          .thenAnswer((_) async => {});

      // Act
      await provider.deleteClassroom(classroom.id);

      // Assert
      expect(provider.classrooms, isEmpty);
      verify(mockService.deleteClassroom(classroom.id)).called(1);
    });

    test('Fetch classrooms and cache them', () async {
      // Arrange
      final classrooms = [
        Classroom(
          id: 1,
          ownerId: 1,
          name: 'Class 1',
          uniqueCode: 'ABC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Classroom(
          id: 2,
          ownerId: 1,
          name: 'Class 2',
          uniqueCode: 'DEF',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockService.getClassrooms())
          .thenAnswer((_) async => classrooms);

      // Act
      await provider.fetchClassrooms();

      // Assert
      expect(provider.classrooms.length, 2);
      expect(provider.isLoading, false);
    });
  });
}
