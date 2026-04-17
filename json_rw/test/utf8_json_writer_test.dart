import 'dart:convert';
import 'package:json_rw/src/utf8_json_writer.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_writer_tests.dart';

void main() {
  group('Utf8JsonWriter', () {
    declareWriterTests((action) {
      late List<int> resultBytes;
      final sink = ByteConversionSink.withCallback((accumulated) {
        resultBytes = accumulated;
      });
      final writer = Utf8JsonWriter(sink);
      action(writer);
      sink.close();
      return utf8.decode(resultBytes);
    });
  });
}
