import 'json_writer.dart';
import 'shared.dart';

enum _JsonScope { object, array }

class PrettyStringJsonWriter implements JsonWriter {
  final StringSink _sink;
  final List<_JsonScope> _stack = [];
  bool _hasValue = false;
  final String _indentStr;

  PrettyStringJsonWriter(this._sink, IndentType type, int? count)
      : _indentStr = _getIndentStr(type, count);

  static String _getIndentStr(IndentType type, int? count) {
    final n = count ?? (type == IndentType.spaces ? 2 : 1);
    return (type == IndentType.spaces ? ' ' : '\t') * n;
  }

  void _indent() {
    _sink.write('\n');
    for (var i = 0; i < _stack.length; i++) {
      _sink.write(_indentStr);
    }
  }

  void _beforeValue() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    if (top == _JsonScope.array) {
      if (_hasValue) {
        _sink.write(',');
      }
      _indent();
      _hasValue = true;
    }
  }

  void _beforeName() {
    if (_hasValue) {
      _sink.write(',');
    }
    _indent();
    _hasValue = true;
  }

  @override
  void beginObject() {
    _beforeValue();
    _sink.write('{');
    _stack.add(_JsonScope.object);
    _hasValue = false;
  }

  @override
  void endObject() {
    _stack.removeLast();
    if (_hasValue) {
      _indent();
    }
    _sink.write('}');
    _hasValue = true;
  }

  @override
  void beginArray() {
    _beforeValue();
    _sink.write('[');
    _stack.add(_JsonScope.array);
    _hasValue = false;
  }

  @override
  void endArray() {
    _stack.removeLast();
    if (_hasValue) {
      _indent();
    }
    _sink.write(']');
    _hasValue = true;
  }

  @override
  void name(String name) {
    _beforeName();
    _writeStringValue(name);
    _sink.write(': ');
  }

  @override
  void writeString(String value) {
    _beforeValue();
    _writeStringValue(value);
  }

  @override
  void writeBool(bool value) {
    _beforeValue();
    _sink.write(value ? 'true' : 'false');
  }

  @override
  void writeNumber(num value) {
    _beforeValue();
    _sink.write(value.toString());
  }

  @override
  void writeNull() {
    _beforeValue();
    _sink.write('null');
  }

  void _writeStringValue(String value) {
    _sink
      ..write('"')
      ..write(escapeString(value))
      ..write('"');
  }
}
