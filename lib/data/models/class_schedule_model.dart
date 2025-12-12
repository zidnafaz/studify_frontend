import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';
import 'user_model.dart';
import 'reminder_model.dart';

part 'class_schedule_model.g.dart';

@JsonSerializable()
class ClassSchedule {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'classroom_id', fromJson: parseInt)
  final int classroomId;
  @JsonKey(name: 'coordinator_1', fromJson: parseIntNullable)
  final int? coordinator1;
  @JsonKey(name: 'coordinator_2', fromJson: parseIntNullable)
  final int? coordinator2;
  final String title;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? location;
  final String? lecturer;
  final String? description;
  final String color;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'coordinator1')
  final User? coordinator1User;
  @JsonKey(name: 'coordinator2')
  final User? coordinator2User;
  final List<Reminder>? reminders;

  ClassSchedule({
    required this.id,
    required this.classroomId,
    this.coordinator1,
    this.coordinator2,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.lecturer,
    this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.coordinator1User,
    this.coordinator2User,
    this.reminders,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) =>
      _$ClassScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ClassScheduleToJson(this);
}
