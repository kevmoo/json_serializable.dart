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

  /// Adds a new chunk of data to process.
  void addChunk(String chunk) {
    _lexer.addChunk(chunk);
    _hasToken = false;
  }

  bool _ensureToken() {
    if (_hasToken) return true;
    return _hasToken = _lexer.nextToken();
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
    if (_lexer.isPartial) {
      throw const FormatException('Partial name not ready');
    }
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
    if (_lexer.isPartial) {
      throw const FormatException('Partial string not ready');
    }
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
    if (_lexer.isPartial) {
      throw const FormatException('Partial keyword not ready');
    }
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
    if (_lexer.isPartial) {
      throw const FormatException('Partial number not ready');
    }
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
    if (_lexer.isPartial) {
      throw const FormatException('Partial null not ready');
    }
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
