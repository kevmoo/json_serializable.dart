import 'json_reader.dart';
import 'json_token.dart';

enum _Scope { object, array }

class StringJsonReader implements JsonReader {
  final String _source;
  int _index = 0;
  JsonToken? _peeked;
  final List<_Scope> _stack = [];
  bool _expectName = false;
  bool _commaConsumed = false;

  StringJsonReader(this._source);

  void _skipWhitespace() {
    while (_index < _source.length) {
      final c = _source.codeUnitAt(_index);
      if (c == 32 || c == 10 || c == 13 || c == 9) {
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

    final c = _source.codeUnitAt(_index);
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
      _ when _isDigit(c) || c == 45 => JsonToken.number, // '-'
      _ => throw FormatException(
        'Unexpected character: ${String.fromCharCode(c)}',
      ),
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
    final c = _source.codeUnitAt(_index);
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
    if (_index < _source.length && _source.codeUnitAt(_index) == 44) {
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
    if (_index >= _source.length || _source.codeUnitAt(_index) != 58) {
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
    StringBuffer? sb;

    while (_index < _source.length) {
      final c = _source.codeUnitAt(_index);
      if (c == 34) break; // '"'
      if (c < 32) {
        throw const FormatException('Control characters must be escaped');
      }
      if (c == 92) {
        // '\\'
        sb ??= StringBuffer()..write(_source.substring(start, _index));
        _index++; // skip escape
        if (_index >= _source.length) {
          throw const FormatException('Unterminated escape');
        }
        final esc = _source.codeUnitAt(_index);
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
            _index++;
            if (_index + 4 > _source.length) {
              throw const FormatException('Invalid unicode escape');
            }
            final hex = _source.substring(_index, _index + 4);
            try {
              final code = int.parse(hex, radix: 16);
              sb.writeCharCode(code);
            } catch (e) {
              throw const FormatException('Invalid unicode escape');
            }
            _index += 3; // skip 3, loop will increment 4th
          default:
            throw FormatException(
              'Invalid escape sequence: \\${String.fromCharCode(esc)}',
            );
        }
      } else {
        sb?.writeCharCode(c);
      }
      _index++;
    }

    if (_index >= _source.length) {
      throw const FormatException('Unterminated string');
    }
    final result =
        sb == null ? _source.substring(start, _index) : sb.toString();
    _index++; // consume closing '"'
    return result;
  }

  @override
  bool nextBool() {
    if (peek() != JsonToken.boolean) {
      throw const FormatException('Expected boolean');
    }
    final c = _source.codeUnitAt(_index);
    _peeked = null;
    if (c == 116) {
      // 't' {
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

    var scanIndex = _index;
    var c = _source.codeUnitAt(scanIndex);
    if (c == 45 /* - */) {
      scanIndex++;
      if (scanIndex < _source.length) {
        c = _source.codeUnitAt(scanIndex);
      } else {
        throw const FormatException('Invalid number');
      }
    }

    if (c == 48 /* '0' */) {
      scanIndex++;
      if (scanIndex < _source.length) {
        c = _source.codeUnitAt(scanIndex);
        if (c >= 48 && c <= 57 /* 0-9 */) {
          throw const FormatException('Leading zeros are not allowed');
        }
      }
    } else if (c == 46 /* '.' */) {
      throw const FormatException('Leading decimal point is not allowed');
    }

    while (_index < _source.length) {
      final c = _source.codeUnitAt(_index);
      if (_isDigit(c) || c == 46 || c == 45) {
        // '.', '-'
        _index++;
      } else {
        break;
      }
    }

    if (_index > start && _source.codeUnitAt(_index - 1) == 46 /* '.' */) {
      throw const FormatException('Trailing decimal point is not allowed');
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
