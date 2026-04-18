import 'package:meta/meta.dart';
import 'bitmask_stack.dart';
import 'byte_chunked_lexer.dart';
import 'chunked_json_reader.dart'; // For NeedsMoreDataException
import 'json_reader.dart';
import 'json_token.dart';

/// A [JsonReader] that processes JSON in chunks as bytes.
///
/// **EXPERIMENTAL**: This implementation is currently slower than decoding
/// bytes to strings first (via `utf8.decoder`) and using `ChunkedJsonReader`,
/// due to the highly optimized native UTF-8 decoder in the Dart VM.
@experimental
class ByteChunkedJsonReader implements JsonReader {
  final ByteChunkedLexer _lexer = ByteChunkedLexer();
  final BitmaskStack _stack = BitmaskStack();
  bool _hasToken = false;
  bool _expectName = false;
  bool _commaConsumed = false;

  /// Callback to fetch more data when needed.
  final List<int>? Function()? _onChunkNeeded;

  /// Creates a [ByteChunkedJsonReader] for parsing JSON in chunks.
  ByteChunkedJsonReader({
    List<int>? Function()? onChunkNeeded,
    List<int>? initialChunk,
  }) : _onChunkNeeded = onChunkNeeded {
    if (initialChunk != null) {
      addChunk(initialChunk);
    }
  }

  /// Adds a new chunk of data to process.
  void addChunk(List<int> chunk) {
    _lexer.addChunk(chunk);
    _hasToken = false;
  }

  bool _ensureToken() {
    if (_hasToken) return true;
    while (!_lexer.nextToken()) {
      if (_onChunkNeeded != null) {
        final next = _onChunkNeeded();
        if (next != null) {
          addChunk(next);
          continue;
        }
      }
      return false;
    }
    _hasToken = true;
    return true;
  }

  void _ensureFullToken(NeedsMoreDataException exception) {
    while (_lexer.isPartial) {
      if (_onChunkNeeded != null) {
        final next = _onChunkNeeded();
        if (next != null) {
          addChunk(next);
          _hasToken = false;
          _ensureToken();
          continue;
        }
      }
      throw exception;
    }
  }

  @override
  JsonToken peek() {
    if (!_ensureToken()) {
      if (_lexer.isPartial) {
        throw NeedsMoreDataException.unexpectedEndOfChunk;
      }
      return JsonToken.eof;
    }

    final token = _lexer.currentToken!;

    if (_expectName && token == JsonToken.string) {
      return JsonToken.name;
    }

    return token;
  }

  @override
  void beginObject() {
    if (peek() != JsonToken.beginObject) {
      throw const FormatException('Expected {');
    }
    _stack.pushObject();
    _hasToken = false; // consume {
    _expectName = true;
    _commaConsumed = false;
  }

  @override
  void endObject() {
    if (peek() != JsonToken.endObject) {
      throw const FormatException('Expected }');
    }
    _stack.popObject();
    _hasToken = false; // consume }
    _afterValue();
  }

  @override
  void beginArray() {
    if (peek() != JsonToken.beginArray) {
      throw const FormatException('Expected [');
    }
    _stack.pushArray();
    _hasToken = false; // consume [
    _commaConsumed = false;
  }

  @override
  void endArray() {
    if (peek() != JsonToken.endArray) {
      throw const FormatException('Expected ]');
    }
    _stack.popArray();
    _hasToken = false; // consume ]
    _afterValue();
  }

  @override
  bool hasNext() {
    var token = peek();
    if (token == JsonToken.comma) {
      _hasToken = false; // consume comma
      _commaConsumed = true;
      if (_stack.isObjectScope) {
        _expectName = true;
      }
      token = peek();
    }
    if (token == JsonToken.endObject || token == JsonToken.endArray) {
      if (_commaConsumed) {
        throw const FormatException('Trailing comma is not allowed');
      }
      return false;
    }
    return token != JsonToken.eof;
  }

  void _afterValue() {
    _expectName = false;
    _commaConsumed = false;
  }

  @override
  String nextName() {
    if (peek() != JsonToken.name) {
      throw const FormatException('Expected property name');
    }
    _ensureFullToken(NeedsMoreDataException.partialName);

    final name = _lexer.stringValue;
    _hasToken = false; // consume string
    _expectName = false;

    if (peek() != JsonToken.colon) {
      throw const FormatException('Expected : after key');
    }
    _hasToken = false; // consume colon

    return name;
  }

  @override
  String nextString() {
    if (peek() != JsonToken.string) {
      throw const FormatException('Expected string');
    }
    _ensureFullToken(NeedsMoreDataException.partialString);

    final value = _lexer.stringValue;
    _hasToken = false; // consume
    _afterValue();
    return value;
  }

  @override
  bool nextBool() {
    if (peek() != JsonToken.boolean) {
      throw const FormatException('Expected boolean');
    }
    _ensureFullToken(NeedsMoreDataException.partialKeyword);

    final value = _lexer.stringValue == 'true';
    _hasToken = false; // consume
    _afterValue();
    return value;
  }

  @override
  num nextNumber() {
    if (peek() != JsonToken.number) {
      throw const FormatException('Expected number');
    }
    _ensureFullToken(NeedsMoreDataException.partialNumber);

    final value = num.parse(_lexer.stringValue);
    _hasToken = false; // consume
    _afterValue();
    return value;
  }

  @override
  void nextNull() {
    if (peek() != JsonToken.nullToken) {
      throw const FormatException('Expected null');
    }
    _ensureFullToken(NeedsMoreDataException.partialNull);

    _hasToken = false; // consume
    _afterValue();
  }

  @override
  void skipValue() {
    final token = peek();
    switch (token) {
      case JsonToken.beginObject:
        beginObject();
        while (hasNext()) {
          nextName();
          skipValue();
        }
        endObject();
      case JsonToken.beginArray:
        beginArray();
        while (hasNext()) {
          skipValue();
        }
        endArray();
      case JsonToken.string:
        nextString();
      case JsonToken.number:
        nextNumber();
      case JsonToken.boolean:
        nextBool();
      case JsonToken.nullToken:
        nextNull();
      default:
        throw FormatException('Unexpected token to skip: $token');
    }
  }
}
