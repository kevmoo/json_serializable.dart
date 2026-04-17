import 'package:json_rw/json_rw.dart';
import 'complex_object.dart';
import 'simple_object.builder.dart';
import 'simple_object.dart';

class ComplexObjectBuilder implements ResumableBuilder<ComplexObject> {
  String? name;
  int? age;
  List<SimpleObject>? objects;
  Map<String, String>? map;

  int state = 0; 
  String? currentKey;

  SimpleObjectBuilder? currentObjectBuilder;
  String? currentMapKey;

  @override
  bool hydrate(ChunkedJsonReader reader) {
    try {
      while (true) {
        switch (state) {
          case 0:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginObject();
            state = 1;
          case 1:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endObject) {
                reader.endObject();
                return true;
              }
              return false; // need more data
            }
            currentKey = reader.nextName();
            if (currentKey == 'name') {
              state = 2;
            } else if (currentKey == 'age') {
              state = 3;
            } else if (currentKey == 'objects') {
              state = 4;
            } else if (currentKey == 'map') {
              state = 7;
            } else {
              reader.skipValue();
            }
          case 2:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            name = reader.nextString();
            state = 1;
          case 3:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            age = reader.nextNumber().toInt();
            state = 1;
          case 4:
            objects = [];
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginArray();
            state = 5;
          case 5:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endArray) {
                reader.endArray();
                state = 1;
                break;
              }
              return false; // need more data
            }
            currentObjectBuilder ??= SimpleObjectBuilder();
            if (currentObjectBuilder!.hydrate(reader)) {
              objects!.add(currentObjectBuilder!.build());
              currentObjectBuilder = null;
            } else {
              return false; 
            }
          case 7:
            map = {};
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginObject();
            state = 8;
          case 8:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endObject) {
                reader.endObject();
                state = 1;
                break;
              }
              return false; // need more data
            }
            currentMapKey = reader.nextName();
            state = 9;
          case 9:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            final value = reader.nextString();
            map![currentMapKey!] = value;
            state = 8;
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
  ComplexObject build() => ComplexObject(
        name: name!,
        age: age!,
        objects: objects!,
        map: map!,
      );
}
