import 'dart:convert';
import 'package:json_rw/src/utf8_json_writer.dart';
import 'shared.dart';

class JsonRwUtf8Benchmark extends JsonBenchmarkBase {
  const JsonRwUtf8Benchmark() : super('json_rw_utf8');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonRw,
  );

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

class JsonRwUtf8SmallBenchmark extends JsonBenchmarkBase {
  const JsonRwUtf8SmallBenchmark() : super('json_rw_utf8_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    List<int>? resultBytes;
    final output = ByteConversionSink.withCallback((accumulated) {
      resultBytes = accumulated;
    });
    final writer = Utf8JsonWriter(output);
    smallObject.toWriter(writer);
    output.close();
    if (resultBytes!.isEmpty) throw StateError('Empty result');
  }
}
