import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'is_coordinator')
  final bool? isCoordinator;
  @JsonKey(name: 'coordinator_schedules')
  final List<CoordinatorSchedule>? coordinatorSchedules;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.isCoordinator,
    this.coordinatorSchedules,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class CoordinatorSchedule {
  final String title;
  final String color;

  CoordinatorSchedule({required this.title, required this.color});

  factory CoordinatorSchedule.fromJson(Map<String, dynamic> json) =>
      _$CoordinatorScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatorScheduleToJson(this);
}
