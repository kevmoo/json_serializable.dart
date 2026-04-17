import 'package:json_rw/src/utf8_json_reader.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwUtf8ReadBenchmark extends JsonBenchmarkBase {
  JsonRwUtf8ReadBenchmark() : super('json_rw_utf8_read');

  @override
  void runImpl() {
    final reader = Utf8JsonReader(largeJsonBytes);
    ComplexObject.fromReader(reader);
  }
}
