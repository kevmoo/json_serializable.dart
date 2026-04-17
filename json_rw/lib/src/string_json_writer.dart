import 'json_writer.dart';

enum _JsonScope { object, array }

class StringJsonWriter implements JsonWriter {
  final StringSink _sink;
  final List<_JsonScope> _stack = [];
  bool _hasValue = false;

  StringJsonWriter(this._sink);

  void _beforeValue() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    if (top == _JsonScope.array) {
      if (_hasValue) {
        _sink.write(',');
      }
      _hasValue = true;
    }
  }

  void _beforeName() {
    if (_hasValue) {
      _sink.write(',');
    }
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
    _sink.write(']');
    _hasValue = true;
  }

  @override
  void name(String name) {
    _beforeName();
    _writeStringValue(name);
    _sink.write(':');
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
      // TODO: Implement full JSON string escaping for performance.
      // This is a simplified version for the POC.
      ..write(value.replaceAll('"', '\\"'))
      ..write('"');
  }
}
