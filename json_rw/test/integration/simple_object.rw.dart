part of 'simple_object.dart';

SimpleObject _$SimpleObjectFromReader(JsonReader reader) =>
    _$SimpleObjectBuilder().parse(reader);

void _$SimpleObjectToWriter(SimpleObject instance, JsonWriter writer) {
  writer
    ..beginObject()
    ..name('value')
    ..writeNumber(instance.value)
    ..endObject();
}

extension type const _$State(int value) {
  static const _$State initial = _$State(0);
  static const _$State expectingKey = _$State(1);
  static const _$State readingValue = _$State(2);
}

class _$SimpleObjectBuilder extends ResumableBuilder<SimpleObject> {
  int? _value;
  _$State _state = _$State.initial;

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
            final key = reader.nextName();
            if (key == 'value') {
              _state = _$State.readingValue;
            } else {
              reader.skipValue();
            }
          case _$State.readingValue:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            _value = reader.nextNumber().toInt();
            _state = _$State.expectingKey;
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
  SimpleObject build() => SimpleObject(_value!);
}
