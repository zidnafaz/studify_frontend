import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'reminder_model.dart';

part 'combined_schedule_model.g.dart';

/// Unified model for both personal and class schedules
@JsonSerializable()
class CombinedSchedule {
  final int id;
  final String type; // 'personal' or 'class'
  final String title;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? location;
  final String? lecturer; // Only for class schedules
  final String? description;
  final String color;
  @JsonKey(name: 'source_id')
  final int? sourceId; // Classroom ID for class schedules, null for personal
  @JsonKey(name: 'source_name')
  final String sourceName; // Classroom name or 'Personal Schedule'

  // Class schedule specific fields
  @JsonKey(name: 'coordinator_1')
  final int? coordinator1;
  @JsonKey(name: 'coordinator_2')
  final int? coordinator2;
  @JsonKey(name: 'coordinator1')
  final User? coordinator1User;
  @JsonKey(name: 'coordinator2')
  final User? coordinator2User;

  final List<Reminder>? reminders;

  CombinedSchedule({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.lecturer,
    this.description,
    required this.color,
    this.sourceId,
    required this.sourceName,
    this.coordinator1,
    this.coordinator2,
    this.coordinator1User,
    this.coordinator2User,
    this.reminders,
  });

  factory CombinedSchedule.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to DateTime
    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Handle potential type mismatches from backend
    if (json['start_time'] != null) {
      json['start_time'] =
          _parseDateTime(json['start_time'])?.toIso8601String() ??
          json['start_time'];
    }
    if (json['end_time'] != null) {
      json['end_time'] =
          _parseDateTime(json['end_time'])?.toIso8601String() ??
          json['end_time'];
    }

    return _$CombinedScheduleFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CombinedScheduleToJson(this);

  bool get isPersonal => type == 'personal';
  bool get isClass => type == 'class';
}

/// Model for available source options (for dropdown)
@JsonSerializable()
class ScheduleSource {
  final String id; // 'all', 'personal', or 'classroom:{id}'
  final String type; // 'all', 'personal', or 'classroom'
  final String name;
  final String description;
  @JsonKey(name: 'classroom_id')
  final int? classroomId; // Only for classroom type

  ScheduleSource({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.classroomId,
  });

  factory ScheduleSource.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSourceFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleSourceToJson(this);
}

/// Response model for combined schedules API
@JsonSerializable()
class CombinedScheduleResponse {
  final List<CombinedSchedule> data;
  final CombinedScheduleMeta meta;

  CombinedScheduleResponse({required this.data, required this.meta});

  factory CombinedScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$CombinedScheduleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CombinedScheduleResponseToJson(this);
}

/// Meta information for combined schedules response
@JsonSerializable()
class CombinedScheduleMeta {
  final int total;
  @JsonKey(name: 'available_sources')
  final List<ScheduleSource> availableSources;
  @JsonKey(name: 'current_filter')
  final String? currentFilter;

  CombinedScheduleMeta({
    required this.total,
    required this.availableSources,
    this.currentFilter,
  });

  factory CombinedScheduleMeta.fromJson(Map<String, dynamic> json) =>
      _$CombinedScheduleMetaFromJson(json);

  Map<String, dynamic> toJson() => _$CombinedScheduleMetaToJson(this);
}
