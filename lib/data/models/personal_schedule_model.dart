import 'package:json_annotation/json_annotation.dart';
import 'reminder_model.dart';

part 'personal_schedule_model.g.dart';

@JsonSerializable()
class PersonalSchedule {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String title;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? location;
  final String? description;
  final String color;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<Reminder>? reminders;

  PersonalSchedule({
    required this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.reminders,
  });

  factory PersonalSchedule.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Handle potential type mismatches from backend
    json['id'] = _toInt(json['id']) ?? json['id'];
    json['user_id'] = _toInt(json['user_id']) ?? json['user_id'];

    return _$PersonalScheduleFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PersonalScheduleToJson(this);
}
