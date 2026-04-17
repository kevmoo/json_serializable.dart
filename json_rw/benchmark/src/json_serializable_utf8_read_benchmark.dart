import 'dart:convert';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableUtf8ReadBenchmark extends JsonBenchmarkBase {
  JsonSerializableUtf8ReadBenchmark() : super('json_serializable_utf8_read');

  @override
  void runImpl() {
    final s = utf8.decode(largeJsonBytes);
    final map = json.decode(s) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}
