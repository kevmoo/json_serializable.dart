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
  bool _commaConsumed = false;

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
    if (c == 125 || c == 93) {
      // '}' or ']'
      if (_commaConsumed) {
        throw const FormatException('Trailing comma is not allowed');
      }
      return false;
    }
    _commaConsumed = false;
    return true;
  }

  void _afterValue() {
    _skipWhitespace();
    if (_index < _source.length && _source[_index] == 44) {
      // ','
      _index++; // consume ','
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
    var hasEscapes = false;

    while (_index < _source.length && _source[_index] != 34) {
      // '"'
      final c = _source[_index];
      if (c < 32) {
        throw const FormatException('Control characters must be escaped');
      }
      if (c == 92) {
        // '\\'
        hasEscapes = true;
        _index++; // skip escape
        if (_index >= _source.length) {
          throw const FormatException('Unterminated escape');
        }
        final esc = _source[_index];
        if (esc != 34 &&
            esc != 92 &&
            esc != 47 &&
            esc != 98 &&
            esc != 102 &&
            esc != 110 &&
            esc != 114 &&
            esc != 116 &&
            esc != 117) {
          throw FormatException(
            'Invalid escape sequence: \\${String.fromCharCode(esc)}',
          );
        }
        if (esc == 117) {
          _index += 4; // skip XXXX
          if (_index >= _source.length) {
            throw const FormatException('Invalid unicode escape');
          }
        }
      }
      _index++;
    }

    if (_index >= _source.length) {
      throw const FormatException('Unterminated string');
    }

    final rawBytes = _source is Uint8List
        ? Uint8List.sublistView(_source, start, _index)
        : _source.sublist(start, _index);

    final result = utf8.decode(rawBytes);
    _index++; // consume closing '"'

    if (!hasEscapes) {
      return result;
    }

    // Decode escapes in the string
    final sb = StringBuffer();
    var i = 0;
    while (i < result.length) {
      final c = result.codeUnitAt(i);
      if (c == 92) {
        // '\\'
        i++;
        final esc = result.codeUnitAt(i);
        switch (esc) {
          case 34:
            sb.writeCharCode(34);
          case 92:
            sb.writeCharCode(92);
          case 47:
            sb.writeCharCode(47);
          case 98:
            sb.writeCharCode(8);
          case 102:
            sb.writeCharCode(12);
          case 110:
            sb.writeCharCode(10);
          case 114:
            sb.writeCharCode(13);
          case 116:
            sb.writeCharCode(9);
          case 117: // u
            final hex = result.substring(i + 1, i + 5);
            final code = int.parse(hex, radix: 16);
            sb.writeCharCode(code);
            i += 4;
        }
      } else {
        sb.writeCharCode(c);
      }
      i++;
    }

    return sb.toString();
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

    // Validate leading zeros
    var checkStr = s;
    if (checkStr.startsWith('-')) {
      checkStr = checkStr.substring(1);
    }
    if (checkStr.startsWith('0') &&
        checkStr.length > 1 &&
        checkStr[1] != '.') {
      throw const FormatException('Leading zeros are not allowed');
    }
    if (checkStr.endsWith('.')) {
      throw const FormatException('Trailing decimal point is not allowed');
    }
    if (checkStr.startsWith('.')) {
      throw const FormatException('Leading decimal point is not allowed');
    }

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
