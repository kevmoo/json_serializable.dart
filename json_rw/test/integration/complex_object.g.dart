part of 'complex_object.dart';

ComplexObject _$ComplexObjectFromReader(JsonReader reader) {
  String? name;
  int? age;
  List<SimpleObject>? objects;
  Map<String, String>? map;

  reader.beginObject();
  while (reader.hasNext()) {
    final propertyName = reader.nextName();
    switch (propertyName) {
      case 'name':
        name = reader.nextString();
      case 'age':
        age = reader.nextNumber().toInt();
      case 'objects':
        objects = [];
        reader.beginArray();
        while (reader.hasNext()) {
          objects.add(SimpleObject.fromReader(reader));
        }
        reader.endArray();
      case 'map':
        map = {};
        reader.beginObject();
        while (reader.hasNext()) {
          final key = reader.nextName();
          final value = reader.nextString();
          map[key] = value;
        }
        reader.endObject();
      default:
        reader.skipValue();
    }
  }
  reader.endObject();

  if (name == null) {
    throw const FormatException('Missing required field: name');
  }
  if (age == null) {
    throw const FormatException('Missing required field: age');
  }
  if (objects == null) {
    throw const FormatException('Missing required field: objects');
  }
  if (map == null) {
    throw const FormatException('Missing required field: map');
  }

  return ComplexObject(name: name, age: age, objects: objects, map: map);
}

void _$ComplexObjectToWriter(ComplexObject instance, JsonWriter writer) {
  writer
    ..beginObject()
    ..name('name')
    ..writeString(instance.name)
    ..name('age')
    ..writeNumber(instance.age)
    ..name('objects')
    ..beginArray();
  for (final obj in instance.objects) {
    obj.toWriter(writer);
  }
  writer
    ..endArray()
    ..name('map')
    ..beginObject();
  for (final entry in instance.map.entries) {
    writer
      ..name(entry.key)
      ..writeString(entry.value);
  }
  writer
    ..endObject()
    ..endObject();
}
