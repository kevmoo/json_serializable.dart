import 'dart:convert';
import 'dart:typed_data';
import 'package:json_rw/json_rw.dart';
import 'package:test/test.dart';
import 'integration/simple_object.dart';

void main() {
  test('JsonWriterConverter', () {
    final obj = SimpleObject(42);
    final converter = JsonWriterConverter<SimpleObject>((o, w) {
      w
        ..beginObject()
        ..name('value')
        ..writeNumber(o.value)
        ..endObject();
    });

    final jsonStr = converter.convert(obj);
    expect(jsonStr, '{"value":42}');
  });

  test('JsonReaderConverter', () {
    const jsonStr = '{"value":42}';
    const converter = JsonReaderConverter<SimpleObject>(SimpleObject.builder);

    final obj = converter.convert(jsonStr);
    expect(obj.value, 42);
  });

  test('JsonWriterConverter streaming', () async {
    final obj1 = SimpleObject(1);
    final obj2 = SimpleObject(2);
    final stream = Stream.fromIterable([obj1, obj2]);

    final converter = JsonWriterConverter<SimpleObject>((o, w) {
      w
        ..beginObject()
        ..name('value')
        ..writeNumber(o.value)
        ..endObject();
    });

    final jsonStream = stream.transform(converter);
    final results = await jsonStream.toList();

    expect(results, ['{"value":1}', '{"value":2}']);
  });

  test('JsonReaderConverter streaming', () async {
    final jsonStream = Stream.fromIterable(['{"value":', '1}', '{"value":2}']);
    const converter = JsonReaderConverter<SimpleObject>(SimpleObject.builder);

    final objects = await jsonStream.transform(converter).toList();

    expect(objects.length, 2);
    expect(objects[0].value, 1);
    expect(objects[1].value, 2);
  });

  test('JsonWriterConverter fuse Utf8Encoder', () {
    final obj = SimpleObject(42);
    final converter = JsonWriterConverter<SimpleObject>((o, w) {
      w
        ..beginObject()
        ..name('value')
        ..writeNumber(o.value)
        ..endObject();
    });

    final fused = converter.fuse(utf8.encoder);
    final bytes = fused.convert(obj);

    expect(bytes, utf8.encode('{"value":42}'));
  });

  test('JsonWriterConverter fuse Utf8Encoder streaming', () async {
    final obj1 = SimpleObject(1);
    final obj2 = SimpleObject(2);
    final stream = Stream.fromIterable([obj1, obj2]);

    final converter = JsonWriterConverter<SimpleObject>((o, w) {
      w
        ..beginObject()
        ..name('value')
        ..writeNumber(o.value)
        ..endObject();
    });

    final fused = converter.fuse(utf8.encoder);
    final byteStream = stream.transform(fused);
    final results = await byteStream.toList();

    expect(results.length, 2);
    expect(results[0], utf8.encode('{"value":1}'));
    expect(results[1], utf8.encode('{"value":2}'));
  });

  test('BytesJsonWriter with indentation', () {
    final builder = BytesBuilder();
    JsonWriter.bytes(builder, indentType: IndentType.spaces, indentCount: 2)
      ..beginObject()
      ..name('value')
      ..writeNumber(42)
      ..endObject();

    final bytes = builder.toBytes();
    const expected = '{\n  "value": 42\n}';

    expect(utf8.decode(bytes), expected);
  });
}
