// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassSchedule _$ClassScheduleFromJson(Map<String, dynamic> json) =>
    ClassSchedule(
      id: parseInt(json['id']),
      classroomId: parseInt(json['classroom_id']),
      coordinator1: parseIntNullable(json['coordinator_1']),
      coordinator2: parseIntNullable(json['coordinator_2']),
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String?,
      lecturer: json['lecturer'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      coordinator1User: json['coordinator1'] == null
          ? null
          : User.fromJson(json['coordinator1'] as Map<String, dynamic>),
      coordinator2User: json['coordinator2'] == null
          ? null
          : User.fromJson(json['coordinator2'] as Map<String, dynamic>),
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassScheduleToJson(ClassSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classroom_id': instance.classroomId,
      'coordinator_1': instance.coordinator1,
      'coordinator_2': instance.coordinator2,
      'title': instance.title,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'location': instance.location,
      'lecturer': instance.lecturer,
      'description': instance.description,
      'color': instance.color,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'coordinator1': instance.coordinator1User,
      'coordinator2': instance.coordinator2User,
      'reminders': instance.reminders,
    };
