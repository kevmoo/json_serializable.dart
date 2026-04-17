import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

void declareWriterTests(
  String Function(void Function(JsonWriter writer) action) runTest,
) {
  test('write simple object', () {
    final result = runTest((writer) {
      writer
        ..beginObject()
        ..name('name')
        ..writeString('John')
        ..name('age')
        ..writeNumber(30)
        ..endObject();
    });

    check(result).equals('{"name":"John","age":30}');
  });

  test('write simple array', () {
    final result = runTest((writer) {
      writer
        ..beginArray()
        ..writeString('a')
        ..writeString('b')
        ..writeNumber(1)
        ..endArray();
    });

    check(result).equals('["a","b",1]');
  });

  test('write nested structure', () {
    final result = runTest((writer) {
      writer
        ..beginObject()
        ..name('tags')
        ..beginArray()
        ..writeString('dart')
        ..writeString('json')
        ..endArray()
        ..endObject();
    });

    check(result).equals('{"tags":["dart","json"]}');
  });

  test('write primitives', () {
    final result = runTest((writer) {
      writer
        ..beginArray()
        ..writeBool(true)
        ..writeBool(false)
        ..writeNull()
        ..endArray();
    });

    check(result).equals('[true,false,null]');
  });
}
