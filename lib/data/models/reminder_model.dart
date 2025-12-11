import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';

part 'reminder_model.g.dart';

@JsonSerializable()
class Reminder {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'remindable_id', fromJson: parseInt)
  final int remindableId;
  @JsonKey(name: 'remindable_type')
  final String remindableType;
  @JsonKey(name: 'minutes_before_start', fromJson: parseInt)
  final int minutesBeforeStart;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.remindableId,
    required this.remindableType,
    required this.minutesBeforeStart,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderToJson(this);
}
