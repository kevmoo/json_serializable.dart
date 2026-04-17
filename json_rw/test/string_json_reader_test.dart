import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('StringJsonReader', () {
    test('read simple object', () {
      final reader = JsonReader.fromString('{"name":"John","age":30}');

      check(reader.peek()).equals(JsonToken.beginObject);
      reader.beginObject();

      check(reader.hasNext()).isTrue();
      check(reader.peek()).equals(JsonToken.name);
      check(reader.nextName()).equals('name');
      check(reader.nextString()).equals('John');

      check(reader.hasNext()).isTrue();
      check(reader.nextName()).equals('age');
      check(reader.nextNumber()).equals(30);

      check(reader.hasNext()).isFalse();
      reader.endObject();
      check(reader.peek()).equals(JsonToken.eof);
    });

    test('read simple array', () {
      final reader = JsonReader.fromString('["a","b",1]')..beginArray();
      check(reader.hasNext()).isTrue();
      check(reader.nextString()).equals('a');
      check(reader.hasNext()).isTrue();
      check(reader.nextString()).equals('b');
      check(reader.hasNext()).isTrue();
      check(reader.nextNumber()).equals(1);
      check(reader.hasNext()).isFalse();
      reader.endArray();
    });

    test('read primitives', () {
      final reader = JsonReader.fromString('[true,false,null]')..beginArray();
      check(reader.nextBool()).isTrue();
      check(reader.nextBool()).isFalse();
      reader
        ..nextNull()
        ..endArray();
    });

    test('skip value', () {
      final reader = JsonReader.fromString('{"tags":["a","b"],"age":30}')
        ..beginObject();
      check(reader.nextName()).equals('tags');
      reader.skipValue(); // Skips the array

      check(reader.nextName()).equals('age');
      check(reader.nextNumber()).equals(30);
      reader.endObject();
    });
  });
}
