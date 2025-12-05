// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
  id: (json['id'] as num).toInt(),
  remindableId: (json['remindable_id'] as num).toInt(),
  remindableType: json['remindable_type'] as String,
  minutesBeforeStart: (json['minutes_before_start'] as num).toInt(),
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
