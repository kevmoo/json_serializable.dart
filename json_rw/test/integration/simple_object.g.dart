part of 'simple_object.dart';

SimpleObject _$SimpleObjectFromReader(JsonReader reader) {
  int? value;

  reader.beginObject();
  while (reader.hasNext()) {
    final propertyName = reader.nextName();
    switch (propertyName) {
      case 'value':
        value = reader.nextNumber().toInt();
      default:
        reader.skipValue();
    }
  }
  reader.endObject();

  if (value == null) {
    throw const FormatException('Missing required field: value');
  }

  return SimpleObject(value);
}

void _$SimpleObjectToWriter(SimpleObject instance, JsonWriter writer) {
  writer
    ..beginObject()
    ..name('value')
    ..writeNumber(instance.value)
    ..endObject();
}
