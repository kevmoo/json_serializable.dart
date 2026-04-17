import 'dart:convert';
import 'package:json_rw/src/utf8_json_writer.dart';
import 'shared.dart';

class JsonRwUtf8Benchmark extends JsonBenchmarkBase {
  JsonRwUtf8Benchmark() : super('json_rw_utf8');

  @override
  void runImpl() {
    List<int>? resultBytes;
    final output = ByteConversionSink.withCallback((accumulated) {
      resultBytes = accumulated;
    });
    final writer = Utf8JsonWriter(output);
    largeObject.toWriter(writer);
    output.close();
    if (resultBytes!.isEmpty) throw StateError('Empty result');
  }
}
