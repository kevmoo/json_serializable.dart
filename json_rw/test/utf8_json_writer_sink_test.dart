// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/src/utf8_json_writer.dart';
import 'package:json_rw/src/utf8_json_writer_sink.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Utf8JsonWriterSink', () {
    test('encode objects in an array', () {
      List<int>? resultBytes;
      final output = ByteConversionSink.withCallback((accumulated) {
        resultBytes = accumulated;
      });
      final writer = Utf8JsonWriter(output);

      writer.beginArray();
      final sink = Utf8JsonWriterSink<String>(writer, (value, w) {
        w.writeString(value);
      });

      sink
        ..add('hello')
        ..add('world')
        ..close();
      writer.endArray();

      output.close();

      check(utf8.decode(resultBytes!)).equals('["hello","world"]');
    });
  });
}
