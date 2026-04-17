part of 'example.dart';

Person _$PersonFromReader(JsonReader reader) {
  String? name;
  int? age;
  List<String>? tags;

  reader.beginObject();
  while (reader.hasNext()) {
    final propertyName = reader.nextName();
    switch (propertyName) {
      case 'name':
        name = reader.nextString();
      case 'age':
        age = reader.nextNumber().toInt();
      case 'tags':
        tags = [];
        reader.beginArray();
        while (reader.hasNext()) {
          tags.add(reader.nextString());
        }
        reader.endArray();
      default:
        reader.skipValue();
    }
  }
  reader.endObject();

  if (name == null) throw const FormatException('Missing required field: name');
  if (age == null) throw const FormatException('Missing required field: age');
  if (tags == null) throw const FormatException('Missing required field: tags');

  return Person(name: name, age: age, tags: tags);
}

void _$PersonToWriter(Person instance, JsonWriter writer) {
  writer
    ..beginObject()
    ..name('name')
    ..writeString(instance.name)
    ..name('age')
    ..writeNumber(instance.age)
    ..name('tags')
    ..beginArray();
  for (final tag in instance.tags) {
    writer.writeString(tag);
  }
  writer
    ..endArray()
    ..endObject();
}
