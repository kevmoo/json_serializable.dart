import 'json_token.dart';

/// A state-machine based lexer that processes JSON chunks.
final class ChunkedLexer {
  // States
  static const int _stateScanning = 0;
  static const int _stateString = 1;
  static const int _stateNumber = 2;
  static const int _stateKeyword = 3;
  static const int _stateEscape = 4;

  int _state = _stateScanning;
  JsonToken? _currentToken;
  bool _isPartial = false;

  // Keyword state
  String _expectedKeyword = '';
  int _keywordMatched = 0;

  // Partial data accumulators
  final StringBuffer _stringBuffer = StringBuffer();
  
  // Current chunk state
  String _currentChunk = '';
  int _index = 0;

  JsonToken? get currentToken => _currentToken;
  bool get isPartial => _isPartial;
  String get stringValue => _stringBuffer.toString();

  /// Adds a new chunk of data to process.
  void addChunk(String chunk) {
    _currentChunk = chunk;
    _index = 0;
  }

  void _skipWhitespace() {
    while (_index < _currentChunk.length) {
      final c = _currentChunk.codeUnitAt(_index);
      if (c == 32 || c == 10 || c == 13 || c == 9) {
        _index++;
      } else {
        break;
      }
    }
  }

  bool _scanString() {
    final start = _index;
    while (_index < _currentChunk.length) {
      final c = _currentChunk.codeUnitAt(_index);
      if (c < 32) {
        throw FormatException('Control character in string: $c');
      }
      if (c == 34) {
        // '"'
        _stringBuffer.write(_currentChunk.substring(start, _index));
        _index++; // consume '"'
        _isPartial = false;
        _state = _stateScanning;
        return true;
      }
      if (c == 92) {
        // '\\'
        _stringBuffer.write(_currentChunk.substring(start, _index));
        _index++; // skip '\\'
        if (_index >= _currentChunk.length) {
          _state = _stateEscape;
          _isPartial = true;
          return true;
        }
        // Handle escape in chunk
        final esc = _currentChunk.codeUnitAt(_index);
        _decodeEscape(esc);
        _index++;
        // Continue scanning after escape
        return _scanString();
      }
      _index++;
    }
    _stringBuffer.write(_currentChunk.substring(start, _index));
    _isPartial = true;
    return true;
  }

  void _decodeEscape(int esc) {
    switch (esc) {
      case 34:
        _stringBuffer.writeCharCode(34);
      case 92:
        _stringBuffer.writeCharCode(92);
      case 47:
        _stringBuffer.writeCharCode(47);
      case 98:
        _stringBuffer.writeCharCode(8);
      case 102:
        _stringBuffer.writeCharCode(12);
      case 110:
        _stringBuffer.writeCharCode(10);
      case 114:
        _stringBuffer.writeCharCode(13);
      case 116:
        _stringBuffer.writeCharCode(9);
      case 117: // u
        if (_index + 4 >= _currentChunk.length) {
          throw const FormatException('Split unicode escape not supported yet');
        }
        final hex = _currentChunk.substring(_index + 1, _index + 5);
        final code = int.parse(hex, radix: 16);
        _stringBuffer.writeCharCode(code);
        _index += 4;
      default:
        throw FormatException(
          'Invalid escape sequence: \\${String.fromCharCode(esc)}',
        );
    }
  }

  bool nextToken() {
    while (true) {
      if (_state == _stateScanning) {
        _skipWhitespace();
      }
      if (_index >= _currentChunk.length) return false;

      final c = _currentChunk.codeUnitAt(_index);
      switch (_state) {
        case _stateScanning:
          if (c == 123) {
            _currentToken = JsonToken.beginObject;
            _index++;
            return true;
          }
          if (c == 125) {
            _currentToken = JsonToken.endObject;
            _index++;
            return true;
          }
          if (c == 91) {
            _currentToken = JsonToken.beginArray;
            _index++;
            return true;
          }
          if (c == 93) {
            _currentToken = JsonToken.endArray;
            _index++;
            return true;
          }
          if (c == 44) {
            _currentToken = JsonToken.comma;
            _index++;
            return true;
          }
          if (c == 58) {
            _currentToken = JsonToken.colon;
            _index++;
            return true;
          }

          if (c == 34) {
            // '"'
            _state = _stateString;
            _index++;
            _stringBuffer.clear();
            continue;
          }
          if (c == 116) {
            // 't'
            _state = _stateKeyword;
            _expectedKeyword = 'true';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if (c == 102) {
            // 'f'
            _state = _stateKeyword;
            _expectedKeyword = 'false';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if (c == 110) {
            // 'n'
            _state = _stateKeyword;
            _expectedKeyword = 'null';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if ((c >= 48 && c <= 57) || c == 45) {
            // 0-9, -
            _state = _stateNumber;
            _stringBuffer.clear();
            continue;
          }
          throw FormatException(
            'Unexpected character: ${String.fromCharCode(c)}',
          );

        case _stateString:
          if (_scanString()) {
            _currentToken = JsonToken.string;
            return true;
          }
          return false;

        case _stateEscape:
          if (_index >= _currentChunk.length) return false;
          final esc = _currentChunk.codeUnitAt(_index);
          _decodeEscape(esc);
          _index++;
          _state = _stateString;
          continue;

        case _stateKeyword:
          while (_index < _currentChunk.length &&
              _keywordMatched < _expectedKeyword.length) {
            final c = _currentChunk.codeUnitAt(_index);
            if (c != _expectedKeyword.codeUnitAt(_keywordMatched)) {
              throw FormatException('Expected $_expectedKeyword');
            }
            _index++;
            _keywordMatched++;
          }
          if (_keywordMatched == _expectedKeyword.length) {
            _state = _stateScanning;
            _currentToken = _expectedKeyword == 'true'
                ? JsonToken.boolean
                : (_expectedKeyword == 'false'
                    ? JsonToken.boolean
                    : JsonToken.nullToken);
            _stringBuffer
              ..clear()
              ..write(_expectedKeyword);
            return true;
          }
          return false;

        case _stateNumber:
          final start = _index;
          while (_index < _currentChunk.length) {
            final c = _currentChunk.codeUnitAt(_index);
            if ((c >= 48 && c <= 57) ||
                c == 45 ||
                c == 46 ||
                c == 101 ||
                c == 69 ||
                c == 43) {
              _index++;
            } else {
              break;
            }
          }
          _stringBuffer.write(_currentChunk.substring(start, _index));
          if (_index < _currentChunk.length) {
            _state = _stateScanning;
            _currentToken = JsonToken.number;

            final fullNumStr = _stringBuffer.toString();
            if (fullNumStr.endsWith('.')) {
              throw const FormatException('Trailing decimal point in number');
            }
            if (fullNumStr.startsWith('0') && fullNumStr.length > 1) {
              final c = fullNumStr.codeUnitAt(1);
              if (c >= 48 && c <= 57) {
                throw const FormatException('Leading zero in number');
              }
            }
            if (fullNumStr.startsWith('-0') && fullNumStr.length > 2) {
              final c = fullNumStr.codeUnitAt(2);
              if (c >= 48 && c <= 57) {
                throw const FormatException('Leading zero in number');
              }
            }

            return true;
          }
          return false;

        default:
          return false;
      }
    }
  }
}
