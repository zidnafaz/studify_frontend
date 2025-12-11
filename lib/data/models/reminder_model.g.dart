// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
  id: parseInt(json['id']),
  remindableId: parseInt(json['remindable_id']),
  remindableType: json['remindable_type'] as String,
  minutesBeforeStart: parseInt(json['minutes_before_start']),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'remindable_id': instance.remindableId,
  'remindable_type': instance.remindableType,
  'minutes_before_start': instance.minutesBeforeStart,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
