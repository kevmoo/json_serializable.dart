import 'dart:convert';
import 'package:json_rw/src/utf8_json_reader.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_reader_tests.dart';

void main() {
  group('Utf8JsonReader', () {
    declareReaderTests((json) => Utf8JsonReader(utf8.encode(json)));
  });
}
