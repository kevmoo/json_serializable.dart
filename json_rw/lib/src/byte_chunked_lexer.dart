import 'dart:convert';
import 'dart:typed_data';
import 'json_token.dart';

extension type const _$State(int _) {
  static const scanning = _$State(0);
  static const string = _$State(1);
  static const number = _$State(2);
  static const keyword = _$State(3);
  static const escape = _$State(4);
}

/// A state-machine based lexer that processes JSON chunks as bytes.
final class ByteChunkedLexer {
  _$State _state = _$State.scanning;
  JsonToken? _currentToken;
  bool _isPartial = false;

  // Keyword state
  String _expectedKeyword = '';
  int _keywordMatched = 0;

  // Partial data accumulators
  final BytesBuilder _bytesBuilder = BytesBuilder();

  // Current chunk state
  List<int> _currentChunk = const [];
  int _index = 0;

  JsonToken? get currentToken => _currentToken;
  bool get isPartial => _isPartial;

  /// Returns the string value of the current token.
  /// Decodes accumulated UTF-8 bytes.
  String get stringValue => utf8.decode(_bytesBuilder.toBytes());

  /// Adds a new chunk of data to process.
  void addChunk(List<int> chunk) {
    _currentChunk = chunk;
    _index = 0;
  }

  void _skipWhitespace() {
    while (_index < _currentChunk.length) {
      final c = _currentChunk[_index];
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
      final c = _currentChunk[_index];
      if (c < 32) {
        throw FormatException('Control character in string: $c');
      }
      if (c == 34) {
        // '"'
        _bytesBuilder.add(_currentChunk.sublist(start, _index));
        _index++; // consume '"'
        _isPartial = false;
        _state = _$State.scanning;
        return true;
      }
      if (c == 92) {
        // '\\'
        _bytesBuilder.add(_currentChunk.sublist(start, _index));
        _index++; // skip '\\'
        if (_index >= _currentChunk.length) {
          _state = _$State.escape;
          _isPartial = true;
          return true;
        }
        // Handle escape in chunk
        final esc = _currentChunk[_index];
        _decodeEscape(esc);
        _index++;
        // Continue scanning after escape
        return _scanString();
      }
      _index++;
    }
    _bytesBuilder.add(_currentChunk.sublist(start, _index));
    _isPartial = true;
    return true;
  }

  void _decodeEscape(int esc) {
    switch (esc) {
      case 34:
        _bytesBuilder.addByte(34);
      case 92:
        _bytesBuilder.addByte(92);
      case 47:
        _bytesBuilder.addByte(47);
      case 98:
        _bytesBuilder.addByte(8);
      case 102:
        _bytesBuilder.addByte(12);
      case 110:
        _bytesBuilder.addByte(10);
      case 114:
        _bytesBuilder.addByte(13);
      case 116:
        _bytesBuilder.addByte(9);
      case 117: // u
        if (_index + 4 >= _currentChunk.length) {
          throw const FormatException('Split unicode escape not supported yet');
        }
        final hexBytes = _currentChunk.sublist(_index + 1, _index + 5);
        final hex = String.fromCharCodes(hexBytes);
        final code = int.parse(hex, radix: 16);
        _bytesBuilder.add(utf8.encode(String.fromCharCode(code)));
        _index += 4;
      default:
        throw FormatException(
          'Invalid escape sequence: \\${String.fromCharCode(esc)}',
        );
    }
  }

  bool nextToken() {
    while (true) {
      if (_state == _$State.scanning) {
        _skipWhitespace();
      }
      if (_index >= _currentChunk.length) return false;

      final c = _currentChunk[_index];
      switch (_state) {
        case _$State.scanning:
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
            _state = _$State.string;
            _index++;
            _bytesBuilder.clear();
            continue;
          }
          if (c == 116) {
            // 't'
            _state = _$State.keyword;
            _expectedKeyword = 'true';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if (c == 102) {
            // 'f'
            _state = _$State.keyword;
            _expectedKeyword = 'false';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if (c == 110) {
            // 'n'
            _state = _$State.keyword;
            _expectedKeyword = 'null';
            _keywordMatched = 1;
            _index++;
            continue;
          }
          if ((c >= 48 && c <= 57) || c == 45) {
            // 0-9, -
            _state = _$State.number;
            _bytesBuilder.clear();
            continue;
          }
          throw FormatException(
            'Unexpected character: ${String.fromCharCode(c)}',
          );

        case _$State.string:
          if (_scanString()) {
            _currentToken = JsonToken.string;
            return true;
          }
          return false;

        case _$State.escape:
          if (_index >= _currentChunk.length) return false;
          final esc = _currentChunk[_index];
          _decodeEscape(esc);
          _index++;
          _state = _$State.string;
          continue;

        case _$State.keyword:
          while (_index < _currentChunk.length &&
              _keywordMatched < _expectedKeyword.length) {
            final c = _currentChunk[_index];
            if (c != _expectedKeyword.codeUnitAt(_keywordMatched)) {
              throw FormatException('Expected $_expectedKeyword');
            }
            _index++;
            _keywordMatched++;
          }
          if (_keywordMatched == _expectedKeyword.length) {
            _state = _$State.scanning;
            _currentToken = _expectedKeyword == 'true'
                ? JsonToken.boolean
                : (_expectedKeyword == 'false'
                      ? JsonToken.boolean
                      : JsonToken.nullToken);
            _bytesBuilder
              ..clear()
              ..add(utf8.encode(_expectedKeyword));
            return true;
          }
          return false;

        case _$State.number:
          final start = _index;
          while (_index < _currentChunk.length) {
            final c = _currentChunk[_index];
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
          _bytesBuilder.add(_currentChunk.sublist(start, _index));
          if (_index < _currentChunk.length) {
            _state = _$State.scanning;
            _currentToken = JsonToken.number;

            final fullNumStr = utf8.decode(_bytesBuilder.toBytes());
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
