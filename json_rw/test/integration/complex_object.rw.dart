part of 'complex_object.dart';

ComplexObject _$ComplexObjectFromReader(JsonReader reader) =>
    _$ComplexObjectBuilder().parse(reader);

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

extension type const _$State(int value) {
  static const _$State initial = _$State(0);
  static const _$State expectingKey = _$State(1);
  static const _$State readingName = _$State(2);
  static const _$State readingAge = _$State(3);
  static const _$State readingObjectsStart = _$State(4);
  static const _$State readingObjectsElements = _$State(5);
  static const _$State readingMapStart = _$State(7);
  static const _$State readingMapKey = _$State(8);
  static const _$State readingMapValue = _$State(9);
}

class _$ComplexObjectBuilder extends ResumableBuilder<ComplexObject> {
  String? _name;
  int? _age;
  List<SimpleObject>? _objects;
  Map<String, String>? _map;

  _$State _state = _$State.initial;
  String? _currentKey;

  ResumableBuilder<SimpleObject>? _currentObjectBuilder;
  String? _currentMapKey;

  @override
  bool hydrate(JsonReader reader) {
    try {
      while (true) {
        switch (_state) {
          case _$State.initial:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginObject();
            _state = _$State.expectingKey;
          case _$State.expectingKey:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endObject) {
                reader.endObject();
                return true;
              }
              return false; // need more data
            }
            _currentKey = reader.nextName();
            if (_currentKey == 'name') {
              _state = _$State.readingName;
            } else if (_currentKey == 'age') {
              _state = _$State.readingAge;
            } else if (_currentKey == 'objects') {
              _state = _$State.readingObjectsStart;
            } else if (_currentKey == 'map') {
              _state = _$State.readingMapStart;
            } else {
              reader.skipValue();
            }
          case _$State.readingName:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            _name = reader.nextString();
            _state = _$State.expectingKey;
          case _$State.readingAge:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            _age = reader.nextNumber().toInt();
            _state = _$State.expectingKey;
          case _$State.readingObjectsStart:
            _objects = [];
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginArray();
            _state = _$State.readingObjectsElements;
          case _$State.readingObjectsElements:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endArray) {
                reader.endArray();
                _state = _$State.expectingKey;
                break;
              }
              return false; // need more data
            }
            _currentObjectBuilder ??= SimpleObject.builder();
            if (_currentObjectBuilder!.hydrate(reader)) {
              _objects!.add(_currentObjectBuilder!.build());
              _currentObjectBuilder = null;
            } else {
              return false;
            }
          case _$State.readingMapStart:
            _map = {};
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginObject();
            _state = _$State.readingMapKey;
          case _$State.readingMapKey:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endObject) {
                reader.endObject();
                _state = _$State.expectingKey;
                break;
              }
              return false; // need more data
            }
            _currentMapKey = reader.nextName();
            _state = _$State.readingMapValue;
          case _$State.readingMapValue:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            final value = reader.nextString();
            _map![_currentMapKey!] = value;
            _state = _$State.readingMapKey;
        }
      }
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        return false;
      }
      rethrow;
    }
  }

  @override
  ComplexObject build() =>
      ComplexObject(name: _name!, age: _age!, objects: _objects!, map: _map!);
}
