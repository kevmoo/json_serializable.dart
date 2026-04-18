import 'dart:typed_data';
import 'string_json_writer.dart';
import 'utf8_json_writer.dart';

enum IndentType { spaces, tabs }

abstract class JsonWriter {
  factory JsonWriter(
    StringSink sink, {
    IndentType? indentType,
    int? indentCount,
  }) => StringJsonWriter(sink, indentType, indentCount);

  factory JsonWriter.bytes(
    BytesBuilder builder, {
    IndentType? indentType,
    int? indentCount,
  }) => Utf8JsonWriter(
    _BytesBuilderSink(builder),
    indentType: indentType,
    indentCount: indentCount,
  );

  void beginObject();
  void endObject();
  void beginArray();
  void endArray();

  /// Writes a property name. Must be followed by a value.
  void name(String name);

  void writeString(String value);
  void writeBool(bool value);
  void writeNumber(num value);
  void writeNull();
}

class _BytesBuilderSink implements Sink<List<int>> {
  final BytesBuilder builder;
  _BytesBuilderSink(this.builder);

  @override
  void add(List<int> data) => builder.add(data);

  @override
  void close() {}
}
