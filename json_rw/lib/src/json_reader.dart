import 'json_token.dart';
import 'string_json_reader.dart';
import 'utf8_json_reader.dart';

abstract class JsonReader {
  factory JsonReader.fromString(String source) => StringJsonReader(source);
  factory JsonReader.fromUtf8(List<int> source) => Utf8JsonReader(source);

  /// Returns the type of the next token without consuming it.
  JsonToken peek();

  /// Consumes the next token and asserts it is the start of an object.
  void beginObject();

  /// Consumes the next token and asserts it is the end of an object.
  void endObject();

  /// Consumes the next token and asserts it is the start of an array.
  void beginArray();

  /// Consumes the next token and asserts it is the end of an array.
  void endArray();

  /// Returns true if the current object or array has more elements.
  bool hasNext();

  /// Consumes the next token as a property name.
  String nextName();

  /// Consumes the next token as a string.
  String nextString();

  /// Consumes the next token as a boolean.
  bool nextBool();

  /// Consumes the next token as a number.
  num nextNumber();

  /// Consumes the next token as null.
  void nextNull();

  /// Skips the next value (and all its children if it is an object/array).
  void skipValue();
}
