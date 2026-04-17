import 'package:json_rw/src/utf8_json_reader.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwUtf8ReadBenchmark extends JsonBenchmarkBase {
  const JsonRwUtf8ReadBenchmark() : super('json_rw_utf8_read');

  @override
  void runImpl() {
    final reader = Utf8JsonReader(largeJsonBytes);
    ComplexObject.fromReader(reader);
  }
}

class JsonRwUtf8ReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonRwUtf8ReadSmallBenchmark() : super('json_rw_utf8_read_small');

  @override
  void runImpl() {
    final reader = Utf8JsonReader(smallJsonBytes);
    ComplexObject.fromReader(reader);
  }
}
