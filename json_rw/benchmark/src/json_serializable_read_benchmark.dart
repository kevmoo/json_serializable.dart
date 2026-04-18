import 'dart:convert';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableReadBenchmark extends JsonBenchmarkBase {
  const JsonSerializableReadBenchmark() : super('json_serializable_read');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

  @override
  void runImpl() {
    final map = json.decode(largeJsonString) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}

class JsonSerializableReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonSerializableReadSmallBenchmark()
    : super('json_serializable_read_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

  @override
  void runImpl() {
    final map = json.decode(smallJsonString) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}
