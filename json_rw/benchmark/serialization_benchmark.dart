import 'dart:convert';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:json_rw/src/string_json_reader.dart';
import 'package:json_rw/src/string_json_writer.dart';
import 'package:json_rw/src/utf8_json_reader.dart';
import 'package:json_rw/src/utf8_json_writer.dart';
import '../test/integration/complex_object.dart';
import '../test/integration/simple_object.dart';

// A large object to benchmark
final largeObject = ComplexObject(
  name: 'Complex Object',
  age: 42,
  objects: List.generate(1000, SimpleObject.new),
  map: {for (var i = 0; i < 100; i++) 'key$i': 'value$i'},
);

final largeJsonString = json.encode(largeObject.toJson());
final largeJsonBytes = utf8.encode(largeJsonString);

class JsonSerializableBenchmark extends BenchmarkBase {
  JsonSerializableBenchmark() : super('json_serializable');

  @override
  void run() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    if (s.isEmpty) throw StateError('Empty result');
  }
}

class JsonRwBenchmark extends BenchmarkBase {
  JsonRwBenchmark() : super('json_rw');

  @override
  void run() {
    final sb = StringBuffer();
    final writer = StringJsonWriter(sb);
    largeObject.toWriter(writer);
    final s = sb.toString();
    if (s.isEmpty) throw StateError('Empty result');
  }
}

class JsonSerializableUtf8Benchmark extends BenchmarkBase {
  JsonSerializableUtf8Benchmark() : super('json_serializable_utf8');

  @override
  void run() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    final bytes = utf8.encode(s);
    if (bytes.isEmpty) throw StateError('Empty result');
  }
}

class JsonRwUtf8Benchmark extends BenchmarkBase {
  JsonRwUtf8Benchmark() : super('json_rw_utf8');

  @override
  void run() {
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

class JsonSerializableReadBenchmark extends BenchmarkBase {
  JsonSerializableReadBenchmark() : super('json_serializable_read');

  @override
  void run() {
    final map = json.decode(largeJsonString) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}

class JsonRwReadBenchmark extends BenchmarkBase {
  JsonRwReadBenchmark() : super('json_rw_read');

  @override
  void run() {
    final reader = StringJsonReader(largeJsonString);
    ComplexObject.fromReader(reader);
  }
}

class JsonSerializableUtf8ReadBenchmark extends BenchmarkBase {
  JsonSerializableUtf8ReadBenchmark() : super('json_serializable_utf8_read');

  @override
  void run() {
    final s = utf8.decode(largeJsonBytes);
    final map = json.decode(s) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}

class JsonRwUtf8ReadBenchmark extends BenchmarkBase {
  JsonRwUtf8ReadBenchmark() : super('json_rw_utf8_read');

  @override
  void run() {
    final reader = Utf8JsonReader(largeJsonBytes);
    ComplexObject.fromReader(reader);
  }
}

void main() {
  JsonSerializableBenchmark().report();
  JsonRwBenchmark().report();
  JsonSerializableUtf8Benchmark().report();
  JsonRwUtf8Benchmark().report();
  JsonSerializableReadBenchmark().report();
  JsonRwReadBenchmark().report();
  JsonSerializableUtf8ReadBenchmark().report();
  JsonRwUtf8ReadBenchmark().report();
}
