import 'package:json_rw/src/string_json_writer.dart';
import 'shared.dart';

class JsonRwBenchmark extends JsonBenchmarkBase {
  JsonRwBenchmark() : super('json_rw');

  @override
  void runImpl() {
    final sb = StringBuffer();
    final writer = StringJsonWriter(sb);
    largeObject.toWriter(writer);
    final s = sb.toString();
    if (s.isEmpty) throw StateError('Empty result');
  }
}
