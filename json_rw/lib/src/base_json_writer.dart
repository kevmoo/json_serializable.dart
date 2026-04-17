import 'json_writer.dart';
import 'shared.dart';

enum _JsonScope { object, array }

abstract class BaseJsonWriter implements JsonWriter {
  final List<_JsonScope> _stack = [];
  bool _hasValue = false;
  final String? _indentStr;
  int _indentLevel = 0;

  BaseJsonWriter(IndentType? indentType, int? indentCount)
      : _indentStr = _getIndentStr(indentType, indentCount);

  static String? _getIndentStr(IndentType? type, int? count) {
    if (type == null) return null;
    final n = count ?? (type == IndentType.spaces ? 2 : 1);
    return (type == IndentType.spaces ? ' ' : '\t') * n;
  }

  // Abstract methods to be implemented by subclasses
  void writeRawString(String s);
  void writeRawChar(int c);

  void _indent() {
    if (_indentStr == null) return;
    writeRawChar(10); // '\n'
    for (var i = 0; i < _indentLevel; i++) {
      writeRawString(_indentStr);
    }
  }

  void _beforeValue() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    if (top == _JsonScope.array) {
      if (_hasValue) {
        writeRawChar(44); // ','
      }
      _indent();
      _hasValue = true;
    }
  }

  void _beforeName() {
    if (_hasValue) {
      writeRawChar(44); // ','
    }
    _indent();
    _hasValue = true;
  }

  @override
  void beginObject() {
    _beforeValue();
    writeRawChar(123); // '{'
    _stack.add(_JsonScope.object);
    _hasValue = false;
    _indentLevel++;
  }

  @override
  void endObject() {
    _stack.removeLast();
    _indentLevel--;
    if (_hasValue && _indentStr != null) {
      _indent();
    }
    writeRawChar(125); // '}'
    _hasValue = true;
  }

  @override
  void beginArray() {
    _beforeValue();
    writeRawChar(91); // '['
    _stack.add(_JsonScope.array);
    _hasValue = false;
    _indentLevel++;
  }

  @override
  void endArray() {
    _stack.removeLast();
    _indentLevel--;
    if (_hasValue && _indentStr != null) {
      _indent();
    }
    writeRawChar(93); // ']'
    _hasValue = true;
  }

  @override
  void name(String name) {
    _beforeName();
    _writeStringValue(name);
    writeRawChar(58); // ':'
    if (_indentStr != null) {
      writeRawChar(32); // ' '
    }
  }

  @override
  void writeString(String value) {
    _beforeValue();
    _writeStringValue(value);
  }

  @override
  void writeBool(bool value) {
    _beforeValue();
    writeRawString(value ? 'true' : 'false');
  }

  @override
  void writeNumber(num value) {
    _beforeValue();
    writeRawString(value.toString());
  }

  @override
  void writeNull() {
    _beforeValue();
    writeRawString('null');
  }

  void _writeStringValue(String value) {
    writeRawChar(34); // '"'
    writeRawString(escapeString(value));
    writeRawChar(34); // '"'
  }
}
