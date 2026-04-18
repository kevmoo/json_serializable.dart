import 'dart:convert';
import 'shared.dart';

class JsonSerializableBenchmark extends JsonBenchmarkBase {
  const JsonSerializableBenchmark() : super('json_serializable');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonSerializable,
  );

  @override
  void runImpl() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    if (s.isEmpty) throw StateError('Empty result');
  }
}

class JsonSerializableSmallBenchmark extends JsonBenchmarkBase {
  const JsonSerializableSmallBenchmark() : super('json_serializable_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonSerializable,
  );

  @override
  void runImpl() {
    final map = smallObject.toJson();
    final s = json.encode(map);
    if (s.isEmpty) throw StateError('Empty result');
  }
}
