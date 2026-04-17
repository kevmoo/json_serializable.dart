// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complex_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplexObject _$ComplexObjectFromJson(Map<String, dynamic> json) =>
    ComplexObject(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      objects: (json['objects'] as List<dynamic>)
          .map((e) => SimpleObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      map: Map<String, String>.from(json['map'] as Map),
    );

Map<String, dynamic> _$ComplexObjectToJson(ComplexObject instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'objects': instance.objects,
      'map': instance.map,
    };
