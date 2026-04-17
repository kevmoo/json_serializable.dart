import 'dart:typed_data';
import 'bytes_json_writer.dart';
import 'string_json_writer.dart';

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
  }) => BytesJsonWriter(builder, indentType, indentCount);
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
