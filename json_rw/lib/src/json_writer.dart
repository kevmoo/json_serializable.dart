import 'string_json_writer.dart';

abstract class JsonWriter {
  factory JsonWriter(StringSink sink) => StringJsonWriter(sink);
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
