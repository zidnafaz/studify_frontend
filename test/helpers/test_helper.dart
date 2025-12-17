import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:studify/core/http/dio_client.dart';
import 'package:studify/data/services/auth_service.dart';
import 'package:studify/data/services/classroom_service.dart';
import 'package:studify/data/services/class_schedule_service.dart';
import 'package:studify/data/services/combined_schedule_service.dart';
import 'package:studify/data/services/notification_service.dart';

@GenerateMocks([
  Dio,
  DioClient,
  FirebaseMessaging,
  AuthService,
  ClassroomService,
  ClassScheduleService,
  CombinedScheduleService,
  NotificationService,
])
void main() {}
