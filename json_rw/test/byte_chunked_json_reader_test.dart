import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/src/byte_chunked_json_reader.dart';
import 'package:json_rw/src/chunked_json_reader.dart'; // For NeedsMoreDataException
import 'package:test/scaffolding.dart';
import 'src/shared_reader_tests.dart';

void main() {
  group('ByteChunkedJsonReader', () {
    declareReaderTests(
      (json) => ByteChunkedJsonReader(initialChunk: utf8.encode(json)),
    );

    test('simple object', () {
      final reader = ByteChunkedJsonReader(
        initialChunk: utf8.encode('{"name": "John"}'),
      )..beginObject();

      check(reader.hasNext()).isTrue();
      check(reader.nextName()).equals('name');
      check(reader.nextString()).equals('John');
      check(reader.hasNext()).isFalse();
      reader.endObject();
    });

    test('partial chunk - wait for name', () {
      final reader = ByteChunkedJsonReader(initialChunk: utf8.encode('{"na'))
        ..beginObject();

      check(reader.nextName).throws<NeedsMoreDataException>();

      reader.addChunk(utf8.encode('me": "John"}'));
      check(reader.nextName()).equals('name');
      check(reader.nextString()).equals('John');
      reader.endObject();
    });

    test('partial chunk - wait for string', () {
      final reader = ByteChunkedJsonReader(
        initialChunk: utf8.encode('{"name": "Jo'),
      )..beginObject();

      check(reader.nextName()).equals('name');
      check(reader.nextString).throws<NeedsMoreDataException>();

      reader.addChunk(utf8.encode('hn"}'));
      check(reader.nextString()).equals('John');
      reader.endObject();
    });

    test('pull parsing with callback', () {
      final chunks = [
        utf8.encode('{"name":'),
        utf8.encode(' "John"'),
        utf8.encode('}'),
      ];
      var chunkIndex = 0;

      final reader = ByteChunkedJsonReader(
        onChunkNeeded: () {
          if (chunkIndex < chunks.length) {
            return chunks[chunkIndex++];
          }
          return null;
        },
      )..beginObject();

      check(reader.nextName()).equals('name');
      check(reader.nextString()).equals('John');
      reader.endObject();
    });
  });
}
