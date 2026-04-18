import 'package:json_rw/src/string_json_reader.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwReadBenchmark extends JsonBenchmarkBase {
  const JsonRwReadBenchmark() : super('json_rw_read');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final reader = StringJsonReader(largeJsonString);
    ComplexObject.fromReader(reader);
  }
}

class JsonRwReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonRwReadSmallBenchmark() : super('json_rw_read_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final reader = StringJsonReader(smallJsonString);
    ComplexObject.fromReader(reader);
  }
}
