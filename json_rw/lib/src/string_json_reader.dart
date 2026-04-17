import 'json_reader.dart';
import 'json_token.dart';

enum _Scope { object, array }

class StringJsonReader implements JsonReader {
  final String _source;
  int _index = 0;
  JsonToken? _peeked;
  final List<_Scope> _stack = [];
  bool _expectName = false;

  StringJsonReader(this._source);

  void _skipWhitespace() {
    while (_index < _source.length) {
      final c = _source[_index];
      if (c == ' ' || c == '\n' || c == '\r' || c == '\t') {
        _index++;
      } else {
        break;
      }
    }
  }

  @override
  JsonToken peek() {
    if (_peeked != null) return _peeked!;
    _skipWhitespace();
    if (_index >= _source.length) return JsonToken.eof;

    final c = _source[_index];
    if (_expectName) {
      if (c == '"') {
        _peeked = JsonToken.name;
        return _peeked!;
      } else if (c == '}') {
        _peeked = JsonToken.endObject;
        return _peeked!;
      }
    }

    switch (c) {
      case '{':
        _peeked = JsonToken.beginObject;
      case '}':
        _peeked = JsonToken.endObject;
      case '[':
        _peeked = JsonToken.beginArray;
      case ']':
        _peeked = JsonToken.endArray;
      case '"':
        _peeked = JsonToken.string;
      case 't':
      case 'f':
        _peeked = JsonToken.boolean;
      case 'n':
        _peeked = JsonToken.nullToken;
      default:
        if (_isDigit(c) || c == '-') {
          _peeked = JsonToken.number;
        } else {
          throw FormatException('Unexpected character: $c');
        }
    }
    return _peeked!;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  @override
  void beginObject() {
    if (peek() != JsonToken.beginObject) {
      throw const FormatException('Expected {');
    }
    _index++; // consume '{'
    _peeked = null;
    _stack.add(_Scope.object);
    _expectName = true;
  }

  @override
  void endObject() {
    if (peek() != JsonToken.endObject) {
      throw const FormatException('Expected }');
    }
    _index++; // consume '}'
    _peeked = null;
    _stack.removeLast();
    _expectName = _stack.isNotEmpty && _stack.last == _Scope.object;
    _afterValue();
  }

  @override
  void beginArray() {
    if (peek() != JsonToken.beginArray) {
      throw const FormatException('Expected [');
    }
    _index++; // consume '['
    _peeked = null;
    _stack.add(_Scope.array);
    _expectName = false;
  }

  @override
  void endArray() {
    if (peek() != JsonToken.endArray) throw const FormatException('Expected ]');
    _index++; // consume ']'
    _peeked = null;
    _stack.removeLast();
    _expectName = _stack.isNotEmpty && _stack.last == _Scope.object;
    _afterValue();
  }

  @override
  bool hasNext() {
    _skipWhitespace();
    if (_index >= _source.length) return false;
    final c = _source[_index];
    if (c == '}' || c == ']') return false;
    return true;
  }

  void _afterValue() {
    _skipWhitespace();
    if (_index < _source.length && _source[_index] == ',') {
      _index++; // consume ','
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
    final name = _readString();
    _skipWhitespace();
    if (_index >= _source.length || _source[_index] != ':') {
      throw const FormatException('Expected : after name');
    }
    _index++; // consume ':'
    _peeked = null;
    _expectName = false;
    return name;
  }

  @override
  String nextString() {
    if (peek() != JsonToken.string) {
      throw const FormatException('Expected string');
    }
    final s = _readString();
    _peeked = null;
    _afterValue();
    return s;
  }

  String _readString() {
    _index++; // consume initial '"'
    final start = _index;
    while (_index < _source.length && _source[_index] != '"') {
      if (_source[_index] == '\\') {
        _index++; // skip escape
      }
      _index++;
    }
    final s = _source.substring(start, _index);
    _index++; // consume closing '"'
    return s;
  }

  @override
  bool nextBool() {
    if (peek() != JsonToken.boolean) {
      throw const FormatException('Expected boolean');
    }
    final c = _source[_index];
    _peeked = null;
    if (c == 't') {
      _index += 4; // true
      _afterValue();
      return true;
    } else {
      _index += 5; // false
      _afterValue();
      return false;
    }
  }

  @override
  num nextNumber() {
    if (peek() != JsonToken.number) {
      throw const FormatException('Expected number');
    }
    final start = _index;
    while (_index < _source.length &&
        (_isDigit(_source[_index]) ||
            _source[_index] == '.' ||
            _source[_index] == '-')) {
      _index++;
    }
    final s = _source.substring(start, _index);
    _peeked = null;
    _afterValue();
    return num.parse(s);
  }

  @override
  void nextNull() {
    if (peek() != JsonToken.nullToken) {
      throw const FormatException('Expected null');
    }
    _index += 4; // null
    _peeked = null;
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
      case JsonToken.name:
        nextName();
      case JsonToken.string:
        nextString();
      case JsonToken.number:
        nextNumber();
      case JsonToken.boolean:
        nextBool();
      case JsonToken.nullToken:
        nextNull();
      default:
        throw FormatException('Cannot skip token $token');
    }
  }
}
