import 'package:json_rw/src/utf8_json_reader.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwUtf8ReadBenchmark extends JsonBenchmarkBase {
  const JsonRwUtf8ReadBenchmark() : super('json_rw_utf8_read');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final reader = Utf8JsonReader(largeJsonBytes);
    ComplexObject.fromReader(reader);
  }
}

class JsonRwUtf8ReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonRwUtf8ReadSmallBenchmark() : super('json_rw_utf8_read_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.utf8,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final reader = Utf8JsonReader(smallJsonBytes);
    ComplexObject.fromReader(reader);
  }
}
