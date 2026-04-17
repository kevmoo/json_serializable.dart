import 'chunked_json_reader.dart';
import 'json_token.dart';

/// A [ChunkedJsonReader] that automatically pulls chunks from an [Iterator]
/// when the current chunk is exhausted or contains a partial token.
///
/// This allows for synchronous pull-parsing over fragmented data sources
/// (like a sequence of buffers) without loading all data into a single string.
class ChunkedSequenceJsonReader extends ChunkedJsonReader {
  final Iterator<String> _chunks;

  ChunkedSequenceJsonReader(this._chunks) {
    if (_chunks.moveNext()) {
      addChunk(_chunks.current);
    }
  }

  @override
  JsonToken peek() {
    try {
      final token = super.peek();
      if (token == JsonToken.eof && _chunks.moveNext()) {
        addChunk(_chunks.current);
        return peek(); // Retry with new chunk
      }
      return token;
    } catch (e) {
      if (e is FormatException &&
          (e.toString().contains('Unexpected end of chunk') ||
              e.toString().contains('not ready'))) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          return peek(); // Retry with new chunk
        }
      }
      rethrow;
    }
  }

  @override
  String nextName() {
    try {
      return super.nextName();
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          return nextName(); // Retry
        }
      }
      rethrow;
    }
  }

  @override
  String nextString() {
    try {
      return super.nextString();
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          return nextString(); // Retry
        }
      }
      rethrow;
    }
  }

  @override
  bool nextBool() {
    try {
      return super.nextBool();
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          return nextBool(); // Retry
        }
      }
      rethrow;
    }
  }

  @override
  num nextNumber() {
    try {
      return super.nextNumber();
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          return nextNumber(); // Retry
        }
      }
      rethrow;
    }
  }

  @override
  void nextNull() {
    try {
      super.nextNull();
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        if (_chunks.moveNext()) {
          addChunk(_chunks.current);
          nextNull(); // Retry
          return;
        }
      }
      rethrow;
    }
  }
}
