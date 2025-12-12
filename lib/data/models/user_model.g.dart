// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: parseInt(json['id']),
  name: json['name'] as String,
  email: json['email'] as String,
  emailVerifiedAt: json['email_verified_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  isCoordinator: json['is_coordinator'] as bool?,
  coordinatorSchedules: (json['coordinator_schedules'] as List<dynamic>?)
      ?.map((e) => CoordinatorSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'email_verified_at': instance.emailVerifiedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'is_coordinator': instance.isCoordinator,
  'coordinator_schedules': instance.coordinatorSchedules,
};

CoordinatorSchedule _$CoordinatorScheduleFromJson(Map<String, dynamic> json) =>
    CoordinatorSchedule(
      title: json['title'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$CoordinatorScheduleToJson(
  CoordinatorSchedule instance,
) => <String, dynamic>{'title': instance.title, 'color': instance.color};
