import 'dart:convert';
import 'json_writer.dart';
import 'shared.dart';

enum _JsonScope { object, array }

class Utf8JsonWriter implements JsonWriter {
  final Sink<List<int>> _sink;
  final List<_JsonScope> _stack = [];
  bool _hasValue = false;

  Utf8JsonWriter(this._sink);

  void _beforeValue() {
    if (_stack.isEmpty) return;
    final top = _stack.last;
    if (top == _JsonScope.array) {
      if (_hasValue) {
        _sink.add(const [44]); // ','
      }
      _hasValue = true;
    }
  }

  void _beforeName() {
    if (_hasValue) {
      _sink.add(const [44]); // ','
    }
    _hasValue = true;
  }

  @override
  void beginObject() {
    _beforeValue();
    _sink.add(const [123]); // '{'
    _stack.add(_JsonScope.object);
    _hasValue = false;
  }

  @override
  void endObject() {
    _stack.removeLast();
    _sink.add(const [125]); // '}'
    _hasValue = true;
  }

  @override
  void beginArray() {
    _beforeValue();
    _sink.add(const [91]); // '['
    _stack.add(_JsonScope.array);
    _hasValue = false;
  }

  @override
  void endArray() {
    _stack.removeLast();
    _sink.add(const [93]); // ']'
    _hasValue = true;
  }

  @override
  void name(String name) {
    _beforeName();
    _writeStringValue(name);
    _sink.add(const [58]); // ':'
  }

  @override
  void writeString(String value) {
    _beforeValue();
    _writeStringValue(value);
  }

  @override
  void writeBool(bool value) {
    _beforeValue();
    _sink.add(
      value ? const [116, 114, 117, 101] : const [102, 97, 108, 115, 101],
    );
  }

  @override
  void writeNumber(num value) {
    _beforeValue();
    _sink.add(utf8.encode(value.toString()));
  }

  @override
  void writeNull() {
    _beforeValue();
    _sink.add(const [110, 117, 108, 108]);
  }

  void _writeStringValue(String value) {
    _sink
      ..add(const [34]) // '"'
      ..add(utf8.encode(escapeString(value)))
      ..add(const [34]); // '"'
  }
}
