import 'dart:convert';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableUtf8ReadBenchmark extends JsonBenchmarkBase {
  const JsonSerializableUtf8ReadBenchmark()
    : super('json_serializable_utf8_read');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

  @override
  void runImpl() {
    final s = utf8.decode(largeJsonBytes);
    final map = json.decode(s) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}

class JsonSerializableUtf8ReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonSerializableUtf8ReadSmallBenchmark()
    : super('json_serializable_utf8_read_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

  @override
  void runImpl() {
    final s = utf8.decode(smallJsonBytes);
    final map = json.decode(s) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}
