import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'classroom_model.g.dart';

@JsonSerializable()
class Classroom {
  final int id;
  @JsonKey(name: 'owner_id')
  final int ownerId;
  final String name;
  @JsonKey(name: 'unique_code')
  final String uniqueCode;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final User? owner;
  final List<User>? users;

  Classroom({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.uniqueCode,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.users,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
