import 'dart:typed_data';
import 'json_writer.dart';

enum _JsonScope { object, array }

class Utf8JsonWriter implements JsonWriter {
  final Sink<List<int>> _sink;
  final List<_JsonScope> _stack = [];
  bool _hasValue = false;

  static const int _defaultBufferSize = 1024;
  Uint8List _buffer = Uint8List(_defaultBufferSize);
  int _index = 0;

  Utf8JsonWriter(this._sink);

  void _writeByte(int byte) {
    if (_index == _buffer.length) {
      _sink.add(_buffer);
      _buffer = Uint8List(_defaultBufferSize);
      _index = 0;
    }
    _buffer[_index++] = byte;
  }

  void _flush() {
    if (_index > 0) {
      _sink.add(Uint8List.view(_buffer.buffer, 0, _index));
      _buffer = Uint8List(_defaultBufferSize);
      _index = 0;
    }
  }

  void _beforeValue() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    if (top == _JsonScope.array) {
      if (_hasValue) {
        _writeByte(44); // ','
      }
      _hasValue = true;
    }
  }

  void _beforeName() {
    if (_hasValue) {
      _writeByte(44); // ','
    }
    _hasValue = true;
  }

  @override
  void beginObject() {
    _beforeValue();
    _writeByte(123); // '{'
    _stack.add(_JsonScope.object);
    _hasValue = false;
  }

  @override
  void endObject() {
    _stack.removeLast();
    _writeByte(125); // '}'
    _hasValue = true;
    if (_stack.isEmpty) {
      _flush();
    }
  }

  @override
  void beginArray() {
    _beforeValue();
    _writeByte(91); // '['
    _stack.add(_JsonScope.array);
    _hasValue = false;
  }

  @override
  void endArray() {
    _stack.removeLast();
    _writeByte(93); // ']'
    _hasValue = true;
    if (_stack.isEmpty) {
      _flush();
    }
  }

  @override
  void name(String name) {
    _beforeName();
    _writeStringValue(name);
    _writeByte(58); // ':'
  }

  @override
  void writeString(String value) {
    _beforeValue();
    _writeStringValue(value);
    if (_stack.isEmpty) {
      _flush();
    }
  }

  @override
  void writeBool(bool value) {
    _beforeValue();
    if (value) {
      _writeByte(116); // 't'
      _writeByte(114); // 'r'
      _writeByte(117); // 'u'
      _writeByte(101); // 'e'
    } else {
      _writeByte(102); // 'f'
      _writeByte(97); // 'a'
      _writeByte(108); // 'l'
      _writeByte(115); // 's'
      _writeByte(101); // 'e'
    }
    if (_stack.isEmpty) {
      _flush();
    }
  }

  @override
  void writeNumber(num value) {
    _beforeValue();
    final s = value.toString();
    for (var i = 0; i < s.length; i++) {
      _writeByte(s.codeUnitAt(i));
    }
    if (_stack.isEmpty) {
      _flush();
    }
  }

  @override
  void writeNull() {
    _beforeValue();
    _writeByte(110); // 'n'
    _writeByte(117); // 'u'
    _writeByte(108); // 'l'
    _writeByte(108); // 'l'
    if (_stack.isEmpty) {
      _flush();
    }
  }

  void _writeStringValue(String s) {
    _writeByte(34); // '"'

    final length = s.length;
    for (var i = 0; i < length; i++) {
      var charCode = s.codeUnitAt(i);

      if (charCode < 32) {
        _writeByte(92); // '\'
        switch (charCode) {
          case 8: // backspace
            _writeByte(98); // 'b'
          case 9: // tab
            _writeByte(116); // 't'
          case 10: // newline
            _writeByte(110); // 'n'
          case 12: // form feed
            _writeByte(102); // 'f'
          case 13: // carriage return
            _writeByte(114); // 'r'
          default:
            _writeByte(117); // 'u'
            _writeByte(48); // '0'
            _writeByte(48); // '0'
            _writeByte(_hexDigit((charCode >> 4) & 0xf));
            _writeByte(_hexDigit(charCode & 0xf));
        }
      } else if (charCode == 34 || charCode == 92) {
        // '"' or '\'
        _writeByte(92); // '\'
        _writeByte(charCode);
      } else if (charCode <= 0x7f) {
        _writeByte(charCode);
      } else {
        if ((charCode & 0xF800) == 0xD800) {
          if (charCode < 0xDC00 && i + 1 < length) {
            final nextChar = s.codeUnitAt(i + 1);
            if ((nextChar & 0xFC00) == 0xDC00) {
              charCode =
                  0x10000 + ((charCode & 0x3ff) << 10) + (nextChar & 0x3ff);
              _writeFourByteCharCode(charCode);
              i++;
              continue;
            }
          }
          _writeMultiByteCharCode(0xFFFD); // Replacement character
          continue;
        }
        _writeMultiByteCharCode(charCode);
      }
    }

    _writeByte(34); // '"'
  }

  static int _hexDigit(int x) => x < 10 ? 48 + x : 87 + x;

  void _writeMultiByteCharCode(int charCode) {
    if (charCode <= 0x7ff) {
      _writeByte(0xC0 | (charCode >> 6));
      _writeByte(0x80 | (charCode & 0x3f));
      return;
    }
    if (charCode <= 0xffff) {
      _writeByte(0xE0 | (charCode >> 12));
      _writeByte(0x80 | ((charCode >> 6) & 0x3f));
      _writeByte(0x80 | (charCode & 0x3f));
      return;
    }
    _writeFourByteCharCode(charCode);
  }

  void _writeFourByteCharCode(int charCode) {
    _writeByte(0xF0 | (charCode >> 18));
    _writeByte(0x80 | ((charCode >> 12) & 0x3f));
    _writeByte(0x80 | ((charCode >> 6) & 0x3f));
    _writeByte(0x80 | (charCode & 0x3f));
  }
}
