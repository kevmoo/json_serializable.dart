import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_writer_tests.dart';

void main() {
  group('StringJsonWriter', () {
    declareWriterTests((action) {
      final sb = StringBuffer();
      final writer = JsonWriter(sb);
      action(writer);
      return sb.toString();
    });
  });
}
