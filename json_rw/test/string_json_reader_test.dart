import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_reader_tests.dart';

void main() {
  group('StringJsonReader', () {
    declareReaderTests(JsonReader.fromString);
  });
}
