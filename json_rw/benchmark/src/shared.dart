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

abstract class JsonBenchmarkBase extends BenchmarkBase {
  JsonBenchmarkBase(super.name);

  @override
  void run() {
    Timeline.startSync(name);
    runImpl();
    Timeline.finishSync();
  }

  void runImpl();
}
