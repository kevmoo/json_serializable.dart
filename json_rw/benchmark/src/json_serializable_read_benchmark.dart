import 'dart:convert';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableReadBenchmark extends JsonBenchmarkBase {
  JsonSerializableReadBenchmark() : super('json_serializable_read');

  @override
  void runImpl() {
    final map = json.decode(largeJsonString) as Map<String, dynamic>;
    ComplexObject.fromJson(map);
  }
}
