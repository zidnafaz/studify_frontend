// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classroom _$ClassroomFromJson(Map<String, dynamic> json) => Classroom(
  id: parseInt(json['id']),
  ownerId: parseInt(json['owner_id']),
  name: json['name'] as String,
  uniqueCode: json['unique_code'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  owner: json['owner'] == null
      ? null
      : User.fromJson(json['owner'] as Map<String, dynamic>),
  users: (json['users'] as List<dynamic>?)
      ?.map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'name': instance.name,
  'unique_code': instance.uniqueCode,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'owner': instance.owner,
  'users': instance.users,
};
