import 'json_reader.dart';

abstract class ResumableBuilder<T> {
  bool hydrate(JsonReader reader);
  T build();

  T parse(JsonReader reader) {
    if (!hydrate(reader)) {
      throw const FormatException('Unexpected end of JSON input');
    }
    return build();
  }
}
