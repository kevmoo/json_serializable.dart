import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:json_rw/src/utf8_json_reader.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_reader_tests.dart';

void main() {
  group('Utf8JsonReader', () {
    declareReaderTests((json) => Utf8JsonReader(utf8.encode(json)));

    test('read from non-Uint8List', () {
      const json = '"abc"';
      final bytes = utf8.encode(json).toList(); // Convert to normal List<int>
      final reader = Utf8JsonReader(bytes);
      check(reader.peek()).equals(JsonToken.string);
      check(reader.nextString()).equals('abc');
    });
  });
}
