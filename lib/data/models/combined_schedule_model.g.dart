// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combined_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CombinedSchedule _$CombinedScheduleFromJson(Map<String, dynamic> json) =>
    CombinedSchedule(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String?,
      lecturer: json['lecturer'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String,
      sourceId: (json['source_id'] as num?)?.toInt(),
      sourceName: json['source_name'] as String,
      coordinator1: (json['coordinator_1'] as num?)?.toInt(),
      coordinator2: (json['coordinator_2'] as num?)?.toInt(),
      coordinator1User: json['coordinator1'] == null
          ? null
          : User.fromJson(json['coordinator1'] as Map<String, dynamic>),
      coordinator2User: json['coordinator2'] == null
          ? null
          : User.fromJson(json['coordinator2'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CombinedScheduleToJson(CombinedSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'location': instance.location,
      'lecturer': instance.lecturer,
      'description': instance.description,
      'color': instance.color,
      'source_id': instance.sourceId,
      'source_name': instance.sourceName,
      'coordinator_1': instance.coordinator1,
      'coordinator_2': instance.coordinator2,
      'coordinator1': instance.coordinator1User,
      'coordinator2': instance.coordinator2User,
    };

ScheduleSource _$ScheduleSourceFromJson(Map<String, dynamic> json) =>
    ScheduleSource(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      classroomId: (json['classroom_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScheduleSourceToJson(ScheduleSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'classroom_id': instance.classroomId,
    };

CombinedScheduleResponse _$CombinedScheduleResponseFromJson(
  Map<String, dynamic> json,
) => CombinedScheduleResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CombinedSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: CombinedScheduleMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CombinedScheduleResponseToJson(
  CombinedScheduleResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

CombinedScheduleMeta _$CombinedScheduleMetaFromJson(
  Map<String, dynamic> json,
) => CombinedScheduleMeta(
  total: (json['total'] as num).toInt(),
  availableSources: (json['available_sources'] as List<dynamic>)
      .map((e) => ScheduleSource.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentFilter: json['current_filter'] as String?,
);

Map<String, dynamic> _$CombinedScheduleMetaToJson(
  CombinedScheduleMeta instance,
) => <String, dynamic>{
  'total': instance.total,
  'available_sources': instance.availableSources,
  'current_filter': instance.currentFilter,
};
