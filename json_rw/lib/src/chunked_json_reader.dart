import 'chunked_lexer.dart';
import 'json_reader.dart';
import 'json_token.dart';

enum _Scope { object, array }

/// A [JsonReader] that processes JSON in chunks.
class ChunkedJsonReader implements JsonReader {
  final ChunkedLexer _lexer = ChunkedLexer();
  bool _hasToken = false;

  final List<_Scope> _stack = [];
  bool _expectName = false;
  bool _commaConsumed = false;

  /// Callback to fetch more data when needed.
  final String? Function()? _onChunkNeeded;

  /// Creates a [ChunkedJsonReader] for parsing JSON in chunks.
  ///
  /// The [onChunkNeeded] callback is invoked synchronously when the reader
  /// reaches the end of the current chunk but needs more characters to complete
  /// a token (like a string or number) or to find the next token.
  ///
  /// The callback should return the next chunk of JSON data as a [String], or
  /// `null` if the data stream is fully exhausted. This enables
  /// memory-efficient pull-parsing over fragmented data sources without full
  /// buffering.
  ChunkedJsonReader({String? Function()? onChunkNeeded})
    : _onChunkNeeded = onChunkNeeded;

  /// Adds a new chunk of data to process.
  void addChunk(String chunk) {
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

  void _ensureFullToken(String errorMessage) {
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
      throw FormatException(errorMessage);
    }
  }

  @override
  JsonToken peek() {
    if (!_ensureToken()) {
      if (_lexer.isPartial) {
        throw const FormatException('Unexpected end of chunk');
      }
      return JsonToken.eof;
    }

    final token = _lexer.currentToken!;

    // If we are expecting a name, and we see a string, translate it to name!
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
    _hasToken = false; // consume
    _stack.add(_Scope.object);
    _expectName = true;
  }

  @override
  void endObject() {
    if (peek() != JsonToken.endObject) {
      throw const FormatException('Expected }');
    }
    _hasToken = false; // consume
    _stack.removeLast();
    _expectName = _stack.isNotEmpty && _stack.last == _Scope.object;
    _afterValue();
  }

  @override
  void beginArray() {
    if (peek() != JsonToken.beginArray) {
      throw const FormatException('Expected [');
    }
    _hasToken = false; // consume
    _stack.add(_Scope.array);
    _expectName = false;
  }

  @override
  void endArray() {
    if (peek() != JsonToken.endArray) {
      throw const FormatException('Expected ]');
    }
    _hasToken = false; // consume
    _stack.removeLast();
    _expectName = _stack.isNotEmpty && _stack.last == _Scope.object;
    _afterValue();
  }

  @override
  bool hasNext() {
    final token = peek();
    if (token == JsonToken.endObject || token == JsonToken.endArray) {
      if (_commaConsumed) {
        throw const FormatException('Trailing comma is not allowed');
      }
      return false;
    }
    _commaConsumed = false;
    return token != JsonToken.eof;
  }

  void _afterValue() {
    final token = peek();
    if (token == JsonToken.comma) {
      _hasToken = false; // consume ','
      _commaConsumed = true;
      if (_stack.isNotEmpty && _stack.last == _Scope.object) {
        _expectName = true;
      }
    }
  }

  @override
  String nextName() {
    if (peek() != JsonToken.name) {
      throw const FormatException('Expected property name');
    }
    _ensureFullToken('Partial name not ready');

    final name = _lexer.stringValue;
    _hasToken = false; // consume string
    _expectName = false;

    // Now we MUST see a colon!
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
    _ensureFullToken('Partial string not ready');

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
    _ensureFullToken('Partial keyword not ready');

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
    _ensureFullToken('Partial number not ready');

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
    _ensureFullToken('Partial null not ready');

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
      default:
        _hasToken = false; // consume scalar value
        _afterValue();
    }
  }
}
