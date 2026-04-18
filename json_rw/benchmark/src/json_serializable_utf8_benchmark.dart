import 'dart:convert';
import 'shared.dart';

class JsonSerializableUtf8Benchmark extends JsonBenchmarkBase {
  const JsonSerializableUtf8Benchmark() : super('json_serializable_utf8');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonSerializable,
  );

  @override
  void runImpl() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    final bytes = utf8.encode(s);
    if (bytes.isEmpty) throw StateError('Empty result');
  }
}

class JsonSerializableUtf8SmallBenchmark extends JsonBenchmarkBase {
  const JsonSerializableUtf8SmallBenchmark()
    : super('json_serializable_utf8_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonSerializable,
  );

  @override
  void runImpl() {
    final map = smallObject.toJson();
    final s = json.encode(map);
    final bytes = utf8.encode(s);
    if (bytes.isEmpty) throw StateError('Empty result');
  }
}
