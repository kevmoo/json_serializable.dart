import 'dart:typed_data';
import 'json_token.dart';

extension type const _$State(int _) {
  static const scanning = _$State(0);
  static const string = _$State(1);
  static const number = _$State(2);
  static const keyword = _$State(3);
  static const escape = _$State(4);
}

extension type const _$Action(int _) {
  static const whitespace = _$Action(1);
  static const beginObject = _$Action(2);
  static const endObject = _$Action(3);
  static const beginArray = _$Action(4);
  static const endArray = _$Action(5);
  static const comma = _$Action(6);
  static const colon = _$Action(7);
  static const string = _$Action(8);
  static const keywordTrue = _$Action(9);
  static const keywordFalse = _$Action(10);
  static const keywordNull = _$Action(11);
  static const number = _$Action(12);
}

/// A state-machine based lexer that processes JSON chunks.
final class ChunkedLexer {
  static final Uint8List _actions = _createActions();

  _$State _state = _$State.scanning;
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

  bool _scanString() {
    final start = _index;
    while (_index < _currentChunk.length) {
      final c = _currentChunk.codeUnitAt(_index);
      switch (c) {
        case 34: // '"'
          _stringBuffer.write(_currentChunk.substring(start, _index));
          _index++; // consume '"'
          _isPartial = false;
          _state = _$State.scanning;
          return true;
        case 92: // '\\'
          _stringBuffer.write(_currentChunk.substring(start, _index));
          _index++; // skip '\\'
          if (_index >= _currentChunk.length) {
            _state = _$State.escape;
            _isPartial = true;
            return true;
          }
          // Handle escape in chunk
          final esc = _currentChunk.codeUnitAt(_index);
          _decodeEscape(esc);
          _index++;
          // Continue scanning after escape
          return _scanString();
        default:
          if (c < 32) {
            throw FormatException('Control character in string: $c');
          }
          _index++;
      }
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
      if (_index >= _currentChunk.length) return false;

      final c = _currentChunk.codeUnitAt(_index);
      switch (_state) {
        case _$State.scanning:
          final action = c < 128 ? _actions[c] : 0;
          switch (_$Action(action)) {
            case _$Action.whitespace:
              _index++;
              continue;
            case _$Action.beginObject:
              _currentToken = JsonToken.beginObject;
              _index++;
              return true;
            case _$Action.endObject:
              _currentToken = JsonToken.endObject;
              _index++;
              return true;
            case _$Action.beginArray:
              _currentToken = JsonToken.beginArray;
              _index++;
              return true;
            case _$Action.endArray:
              _currentToken = JsonToken.endArray;
              _index++;
              return true;
            case _$Action.comma:
              _currentToken = JsonToken.comma;
              _index++;
              return true;
            case _$Action.colon:
              _currentToken = JsonToken.colon;
              _index++;
              return true;
            case _$Action.string:
              _state = _$State.string;
              _index++;
              _stringBuffer.clear();
              continue;
            case _$Action.keywordTrue:
              _state = _$State.keyword;
              _expectedKeyword = 'true';
              _keywordMatched = 1;
              _index++;
              continue;
            case _$Action.keywordFalse:
              _state = _$State.keyword;
              _expectedKeyword = 'false';
              _keywordMatched = 1;
              _index++;
              continue;
            case _$Action.keywordNull:
              _state = _$State.keyword;
              _expectedKeyword = 'null';
              _keywordMatched = 1;
              _index++;
              continue;
            case _$Action.number:
              _state = _$State.number;
              _stringBuffer.clear();
              continue;
            default:
              throw FormatException(
                'Unexpected character: ${String.fromCharCode(c)}',
              );
          }

        case _$State.string:
          if (_scanString()) {
            _currentToken = JsonToken.string;
            return true;
          }
          return false;

        case _$State.escape:
          if (_index >= _currentChunk.length) return false;
          final esc = _currentChunk.codeUnitAt(_index);
          _decodeEscape(esc);
          _index++;
          _state = _$State.string;
          continue;

        case _$State.keyword:
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
            _state = _$State.scanning;
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

        case _$State.number:
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
            _state = _$State.scanning;
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

Uint8List _createActions() {
  final table = Uint8List(128);
  table[32] = _$Action.whitespace as int; // Space
  table[10] = _$Action.whitespace as int; // LF
  table[13] = _$Action.whitespace as int; // CR
  table[9] = _$Action.whitespace as int; // Tab
  table[123] = _$Action.beginObject as int;
  table[125] = _$Action.endObject as int;
  table[91] = _$Action.beginArray as int;
  table[93] = _$Action.endArray as int;
  table[44] = _$Action.comma as int;
  table[58] = _$Action.colon as int;
  table[34] = _$Action.string as int;
  table[116] = _$Action.keywordTrue as int;
  table[102] = _$Action.keywordFalse as int;
  table[110] = _$Action.keywordNull as int;
  table[45] = _$Action.number as int; // '-'
  for (var i = 48; i <= 57; i++) {
    table[i] = _$Action.number as int; // '0'-'9'
  }
  return table;
}
