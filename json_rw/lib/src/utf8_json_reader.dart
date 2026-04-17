import 'dart:convert';
import 'dart:typed_data';
import 'json_reader.dart';
import 'json_token.dart';

enum _Scope { object, array }

class Utf8JsonReader implements JsonReader {
  final List<int> _source;
  int _index = 0;
  final List<_Scope> _stack = [];
  JsonToken? _peeked;
  bool _expectName = false;

  Utf8JsonReader(this._source);

  void _skipWhitespace() {
    while (_index < _source.length) {
      final c = _source[_index];
      if (c == 32 || c == 10 || c == 13 || c == 9) {
        // ' ', '\n', '\r', '\t'
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
      if (c == 34) {
        // '"'
        return _peeked = JsonToken.name;
      } else if (c == 125) {
        // '}'
        return _peeked = JsonToken.endObject;
      }
    }

    return switch (c) {
      123 => JsonToken.beginObject, // '{'
      125 => JsonToken.endObject, // '}'
      91 => JsonToken.beginArray, // '['
      93 => JsonToken.endArray, // ']'
      34 => JsonToken.string, // '"'
      116 || 102 => JsonToken.boolean, // 't' || 'f'
      110 => JsonToken.nullToken, // 'n'
      _ when _isDigit(c) || c == 45 => JsonToken.number, // '-' or digit
      _ => throw FormatException('Unexpected byte: $c at $_index'),
    };
  }

  bool _isDigit(int c) => c >= 48 && c <= 57;

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
    if (c == 125 || c == 93) return false; // '}' or ']'
    return true;
  }

  void _afterValue() {
    _skipWhitespace();
    if (_index < _source.length && _source[_index] == 44) {
      // ','
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
    if (_index >= _source.length || _source[_index] != 58) {
      // ':'
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
    while (_index < _source.length && _source[_index] != 34) {
      // '"'
      if (_source[_index] == 92) {
        // '\\'
        _index++; // skip escape
      }
      _index++;
    }
    if (_index >= _source.length) {
      throw const FormatException('Unterminated string');
    }
    final result = utf8.decode(
      _source is Uint8List
          ? Uint8List.sublistView(_source, start, _index)
          : _source.sublist(start, _index),
    );
    _index++; // consume closing '"'
    return result;
  }

  @override
  bool nextBool() {
    if (peek() != JsonToken.boolean) {
      throw const FormatException('Expected boolean');
    }
    final c = _source[_index];
    _peeked = null;
    if (c == 116) {
      // 't'
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
    while (_index < _source.length) {
      final c = _source[_index];
      if (_isDigit(c) || c == 45 || c == 46 || c == 101 || c == 69 || c == 43) {
        // digit, -, ., e, E, +
        _index++;
      } else {
        break;
      }
    }
    final s = String.fromCharCodes(_source, start, _index);
    final n = num.parse(s);
    _peeked = null;
    _afterValue();
    return n;
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
