import 'package:json_annotation/json_annotation.dart';
import 'package:json_rw/json_rw.dart';

part 'simple_object.g.dart';
part 'simple_object.rw.dart';

@JsonSerializable()
class SimpleObject {
  final int value;

  SimpleObject(this.value);

  factory SimpleObject.fromJson(Map<String, dynamic> json) =>
      _$SimpleObjectFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleObjectToJson(this);

  factory SimpleObject.fromReader(JsonReader reader) =>
      _$SimpleObjectFromReader(reader);

  void toWriter(JsonWriter writer) => _$SimpleObjectToWriter(this, writer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleObject &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
