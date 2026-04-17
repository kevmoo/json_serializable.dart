import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/src/byte_json_writer_converter.dart';
import 'package:test/scaffolding.dart';
import 'integration/simple_object.dart';

void main() {
  group('ByteJsonWriterConverter', () {
    test('convert', () {
      final obj = SimpleObject(42);
      final converter = ByteJsonWriterConverter<SimpleObject>((o, w) {
        w
          ..beginObject()
          ..name('value')
          ..writeNumber(o.value)
          ..endObject();
      });

      final jsonBytes = converter.convert(obj);
      check(utf8.decode(jsonBytes)).equals('{"value":42}');
    });

    test('streaming', () async {
      final obj1 = SimpleObject(42);
      final obj2 = SimpleObject(43);
      final stream = Stream.fromIterable([obj1, obj2]);

      final converter = ByteJsonWriterConverter<SimpleObject>((o, w) {
        w
          ..beginObject()
          ..name('value')
          ..writeNumber(o.value)
          ..endObject();
      });

      final results = await stream.transform(converter).toList();
      check(results.length).equals(2);
      check(utf8.decode(results[0])).equals('{"value":42}');
      check(utf8.decode(results[1])).equals('{"value":43}');
    });
  });
}
