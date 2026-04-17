import 'package:json_rw/json_rw.dart';

part 'example.g.dart';

class Person {
  final String name;
  final int age;
  final List<String> tags;

  Person({required this.name, required this.age, required this.tags});

  factory Person.fromReader(JsonReader reader) => _$PersonFromReader(reader);

  void toWriter(JsonWriter writer) => _$PersonToWriter(this, writer);
}
