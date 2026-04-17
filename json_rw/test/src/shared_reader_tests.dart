import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

void declareReaderTests(JsonReader Function(String json) createReader) {
  test('read simple object', () {
    final reader = createReader('{"name":"John","age":30}');

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
    final reader = createReader('["a","b",1]')..beginArray();
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
    final reader = createReader('[true,false,null]')..beginArray();
    check(reader.nextBool()).isTrue();
    check(reader.nextBool()).isFalse();
    reader
      ..nextNull()
      ..endArray();
  });

  test('skip value', () {
    final reader = createReader(
      '{"tags":["a","b"],"age":30,"flag":true,"n":null}',
    )..beginObject();
    check(reader.nextName()).equals('tags');
    reader.skipValue(); // Skips the array

    check(reader.nextName()).equals('age');
    check(reader.nextNumber()).equals(30);

    check(reader.nextName()).equals('flag');
    reader.skipValue(); // Skips true

    check(reader.nextName()).equals('n');
    reader
      ..skipValue() // Skips null
      ..endObject();
  });

  test('read with whitespace', () {
    final reader = createReader('  { "name" : "John" , "age" : 30 }  ');

    check(reader.peek()).equals(JsonToken.beginObject);
    reader.beginObject();

    check(reader.hasNext()).isTrue();
    check(reader.nextName()).equals('name');
    check(reader.nextString()).equals('John');

    check(reader.hasNext()).isTrue();
    check(reader.nextName()).equals('age');
    check(reader.nextNumber()).equals(30);

    check(reader.hasNext()).isFalse();
    reader.endObject();
    check(reader.peek()).equals(JsonToken.eof);
  });

  test('skip object', () {
    final reader = createReader('{"obj":{"a":1},"age":30}')..beginObject();
    check(reader.nextName()).equals('obj');
    reader.skipValue(); // Skips the object

    check(reader.nextName()).equals('age');
    check(reader.nextNumber()).equals(30);
    reader.endObject();
  });

  test('invalid JSON', () {
    final reader = createReader('invalid');
    check(reader.beginObject).throws<FormatException>();
  });

  test('read doubles and negatives', () {
    final reader = createReader('[-1.5, 42]')..beginArray();
    check(reader.nextNumber()).equals(-1.5);
    check(reader.nextNumber()).equals(42);
    reader.endArray();
  });

  test('malformed numbers', () {
    // JSON does not allow leading zeros
    check(() {
      createReader('[01]')
        ..beginArray()
        ..nextNumber();
    }).throws<FormatException>();

    // JSON requires digits after decimal point
    check(() {
      createReader('[0.]')
        ..beginArray()
        ..nextNumber();
    }).throws<FormatException>();

    // JSON requires digits before decimal point
    check(() {
      createReader('[.0]')
        ..beginArray()
        ..nextNumber();
    }).throws<FormatException>();
  });

  test('malformed strings', () {
    // Bad escape
    check(() {
      createReader(r'"\a"').nextString();
    }).throws<FormatException>();

    // Control character must be escaped
    check(() {
      final ctrlStr = String.fromCharCodes([34, 10, 34]); // "\n"
      createReader(ctrlStr).nextString();
    }).throws<FormatException>();
  });

  test('malformed structures', () {
    // Keys must be strings
    check(() {
      createReader('{x:10}')
        ..beginObject()
        ..nextName();
    }).throws<FormatException>();

    // Double comma
    check(() {
      createReader('[1,,2]')
        ..beginArray()
        ..nextNumber()
        ..nextNumber();
    }).throws<FormatException>();

    // Trailing comma
    check(() {
      createReader('[1,2,]')
        ..beginArray()
        ..nextNumber()
        ..nextNumber()
        ..hasNext();
    }).throws<FormatException>();
  });
}
