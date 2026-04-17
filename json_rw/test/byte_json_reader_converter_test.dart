import 'dart:convert';
import 'package:checks/checks.dart';
// For comparison if needed
import 'package:json_rw/src/byte_json_reader_converter.dart';
import 'package:test/scaffolding.dart';
import 'integration/simple_object.dart';

void main() {
  group('ByteJsonReaderConverter', () {
    test('convert', () {
      final jsonBytes = utf8.encode('{"value":42}');
      const converter = ByteJsonReaderConverter<SimpleObject>(
        SimpleObject.builder,
      );

      final obj = converter.convert(jsonBytes);
      check(obj.value).equals(42);
    });

    test('streaming', () async {
      final stream = Stream.fromIterable([
        utf8.encode('{"va'),
        utf8.encode('lue":'),
        utf8.encode('42}'),
      ]);

      const converter = ByteJsonReaderConverter<SimpleObject>(
        SimpleObject.builder,
      );

      final obj = await stream.cast<List<int>>().transform(converter).single;
      check(obj.value).equals(42);
    });
  });
}
