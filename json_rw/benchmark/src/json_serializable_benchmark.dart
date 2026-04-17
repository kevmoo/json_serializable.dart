import 'dart:convert';
import 'shared.dart';

class JsonSerializableBenchmark extends JsonBenchmarkBase {
  const JsonSerializableBenchmark() : super('json_serializable');

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
  void runImpl() {
    final map = smallObject.toJson();
    final s = json.encode(map);
    if (s.isEmpty) throw StateError('Empty result');
  }
}
