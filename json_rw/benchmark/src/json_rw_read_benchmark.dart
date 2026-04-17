import 'package:json_rw/src/string_json_reader.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwReadBenchmark extends JsonBenchmarkBase {
  JsonRwReadBenchmark() : super('json_rw_read');

  @override
  void runImpl() {
    final reader = StringJsonReader(largeJsonString);
    ComplexObject.fromReader(reader);
  }
}
