import 'dart:convert';
import 'shared.dart';

class JsonSerializableBenchmark extends JsonBenchmarkBase {
  JsonSerializableBenchmark() : super('json_serializable');

  @override
  void runImpl() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    if (s.isEmpty) throw StateError('Empty result');
  }
}
