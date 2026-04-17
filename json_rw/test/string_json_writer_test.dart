import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('StringJsonWriter', () {
    test('write simple object', () {
      final sb = StringBuffer();
      JsonWriter(sb)
        ..beginObject()
        ..name('name')
        ..writeString('John')
        ..name('age')
        ..writeNumber(30)
        ..endObject();

      check(sb.toString()).equals('{"name":"John","age":30}');
    });

    test('write simple array', () {
      final sb = StringBuffer();
      JsonWriter(sb)
        ..beginArray()
        ..writeString('a')
        ..writeString('b')
        ..writeNumber(1)
        ..endArray();

      check(sb.toString()).equals('["a","b",1]');
    });

    test('write nested structure', () {
      final sb = StringBuffer();
      JsonWriter(sb)
        ..beginObject()
        ..name('tags')
        ..beginArray()
        ..writeString('dart')
        ..writeString('json')
        ..endArray()
        ..endObject();

      check(sb.toString()).equals('{"tags":["dart","json"]}');
    });

    test('write primitives', () {
      final sb = StringBuffer();
      JsonWriter(sb)
        ..beginArray()
        ..writeBool(true)
        ..writeBool(false)
        ..writeNull()
        ..endArray();

      check(sb.toString()).equals('[true,false,null]');
    });
  });
}
