import 'dart:convert';
import 'shared.dart';

class JsonSerializableUtf8Benchmark extends JsonBenchmarkBase {
  const JsonSerializableUtf8Benchmark() : super('json_serializable_utf8');

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
  void runImpl() {
    final map = smallObject.toJson();
    final s = json.encode(map);
    final bytes = utf8.encode(s);
    if (bytes.isEmpty) throw StateError('Empty result');
  }
}
