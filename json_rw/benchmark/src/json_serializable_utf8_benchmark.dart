import 'dart:convert';
import 'shared.dart';

class JsonSerializableUtf8Benchmark extends JsonBenchmarkBase {
  JsonSerializableUtf8Benchmark() : super('json_serializable_utf8');

  @override
  void runImpl() {
    final map = largeObject.toJson();
    final s = json.encode(map);
    final bytes = utf8.encode(s);
    if (bytes.isEmpty) throw StateError('Empty result');
  }
}
