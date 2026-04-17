import 'pretty_string_json_writer.dart';
import 'string_json_writer.dart';

enum IndentType { spaces, tabs }

abstract class JsonWriter {
  factory JsonWriter(
    StringSink sink, {
    IndentType? indentType,
    int? indentCount,
  }) {
    if (indentType != null) {
      return PrettyStringJsonWriter(sink, indentType, indentCount);
    }
    return StringJsonWriter(sink);
  }
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
