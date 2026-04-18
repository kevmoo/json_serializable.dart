import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:benchmark_harness/benchmark_harness.dart';
import '../../test/integration/complex_object.dart';
import '../../test/integration/simple_object.dart';

// A large object to benchmark
final largeObject = ComplexObject(
  name: 'Complex Object',
  age: 42,
  objects: List.generate(1000, SimpleObject.new),
  map: {for (var i = 0; i < 100; i++) 'key$i': 'value$i'},
);

final largeJsonString = json.encode(largeObject.toJson());
final largeJsonBytes = utf8.encode(largeJsonString);

final smallObject = ComplexObject(
  name: 'Small Object',
  age: 42,
  objects: List.generate(5, SimpleObject.new),
  map: {for (var i = 0; i < 5; i++) 'key$i': 'value$i'},
);

final smallJsonString = json.encode(smallObject.toJson());
final smallJsonBytes = utf8.encode(smallJsonString);

enum BenchmarkOp { read, write }

enum BenchmarkSize { small, large }

enum BenchmarkFormat { string, utf8, chunked, file }

enum BenchmarkImpl { jsonRw, jsonSerializable }

typedef BenchmarkMetadata = ({
  BenchmarkOp op,
  BenchmarkSize size,
  BenchmarkFormat format,
  BenchmarkImpl impl,
  String? variant,
});

abstract interface class DescribedBenchmark {
  BenchmarkMetadata get metadata;
  String get name;
  FutureOr<void> report();
}

abstract class JsonBenchmarkBase extends BenchmarkBase
    implements DescribedBenchmark {
  const JsonBenchmarkBase(super.name);

  @override
  void run() {
    Timeline.startSync(name);
    runImpl();
    Timeline.finishSync();
  }

  void runImpl();
}

abstract class AsyncJsonBenchmarkBase extends AsyncBenchmarkBase
    implements DescribedBenchmark {
  const AsyncJsonBenchmarkBase(super.name);

  @override
  Future<void> run() async {
    Timeline.startSync(name);
    await runImpl();
    Timeline.finishSync();
  }

  Future<void> runImpl();
}
