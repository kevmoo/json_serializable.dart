import 'package:checks/checks.dart';
import 'package:json_rw/src/chunked_json_reader.dart';
import 'package:test/scaffolding.dart';
import 'src/shared_reader_tests.dart';

void main() {
  group('ChunkedJsonReader', () {
    test('simple object', () {
      final reader = ChunkedJsonReader()
        ..addChunk('{"name": "John", "age": 30}')
        ..beginObject();

      check(reader.hasNext()).isTrue();
      check(reader.nextName()).equals('name');
      check(reader.nextString()).equals('John');

      check(reader.hasNext()).isTrue();
      check(reader.nextName()).equals('age');
      check(reader.nextNumber()).equals(30);

      check(reader.hasNext()).isFalse();
      reader.endObject();
    });

    test('split object across chunks', () {
      final reader = ChunkedJsonReader()
        ..addChunk('{"name": "Jo')
        ..beginObject();

      check(reader.hasNext()).isTrue();

      // nextName() should process "name" and expect a colon.
      // Since "name" and ":" are fully in the first chunk, nextName() succeeds!
      check(reader.nextName()).equals('name');

      // Now we are at the value "Jo", which is cut off.
      // nextString() should throw because the token is partial.
      check(reader.nextString).throws<NeedsMoreDataException>();

      // Now we add the rest of the string and the rest of the object!
      reader.addChunk('hn", "age": 30}');

      // Now we should be able to read the full string!
      check(reader.nextString()).equals('John');

      check(reader.hasNext()).isTrue();
      check(reader.nextName()).equals('age');
      check(reader.nextNumber()).equals(30);

      check(reader.hasNext()).isFalse();
      reader.endObject();
    });

    test('unterminated string throws NeedsMoreDataException', () {
      final reader = ChunkedJsonReader()..addChunk('"abc');
      check(reader.nextString).throws<NeedsMoreDataException>();
    });
  });

  group('ChunkedJsonReader - Shared Tests', () {
    declareReaderTests((json) => ChunkedJsonReader()..addChunk(json));
  });
}
