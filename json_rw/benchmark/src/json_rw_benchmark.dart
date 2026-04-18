import 'package:json_rw/src/string_json_writer.dart';
import 'shared.dart';

class JsonRwBenchmark extends JsonBenchmarkBase {
  const JsonRwBenchmark() : super('json_rw');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final sb = StringBuffer();
    final writer = StringJsonWriter(sb);
    largeObject.toWriter(writer);
    final s = sb.toString();
    if (s.isEmpty) throw StateError('Empty result');
  }
}

class JsonRwSmallBenchmark extends JsonBenchmarkBase {
  const JsonRwSmallBenchmark() : super('json_rw_small');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.small,
    format: BenchmarkFormat.string,
    impl: BenchmarkImpl.jsonRw,
  );

  @override
  void runImpl() {
    final sb = StringBuffer();
    final writer = StringJsonWriter(sb);
    smallObject.toWriter(writer);
    final s = sb.toString();
    if (s.isEmpty) throw StateError('Empty result');
  }
}
