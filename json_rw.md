# Implementation Plan: `json_rw`

New package in the workspace: `json_rw`

I want to be able to do "streaming" encode/decode of JSON - to/from Strings or
Stream<List<int>> without intermediate JSON objects.

Ideally this could just be an add-on to `json_serializable`.

But to start with need the base types: `JsonReader` and `JsonWriter`.

## Proposed APIs

### JsonReader

A pull-based reader for JSON tokens, similar to GSON's `JsonReader` or C#'s
`Utf8JsonReader`.

```dart
enum JsonToken {
  beginObject,
  endObject,
  beginArray,
  endArray,
  name,
  string,
  number,
  boolean,
  nullToken,
  eof,
}

abstract class JsonReader {
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
```

### JsonWriter

A push-based writer for JSON tokens.

```dart
abstract class JsonWriter {
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
```

## Implementation Plan

1.  **Define Core Types**: Implement `JsonReader` and `JsonWriter` interfaces
    and the `JsonToken` enum.
2.  **String-based Implementation**:
    - Implement `StringJsonReader` that parses JSON from a `String` source.
    - Implement `StringJsonWriter` that writes JSON to a `StringSink`.
3.  **Byte-based Implementation (UTF-8)**:
    - Implement `Utf8JsonReader` that operates directly on `List<int>` to
      avoid intermediate string allocations for tokens.
    - Implement `Utf8JsonWriter` that writes UTF-8 bytes to a `Sink<List<int>>`.
4.  **Streaming Support**:
    - For `Stream<List<int>>` (and `Stream<String>`), use a push-based model
      aligned with `dart:convert`'s `ChunkedConversionSink`.
    - Implement a push parser that receives chunks of data and calls listener
      methods or drives a state machine to build objects directly, avoiding
      `Future` overhead per token.
5.  **Integration with `json_serializable`**:
    - Use convention-based detection to identify if a class supports
      `JsonReader`/`JsonWriter` (e.g., looking for a `fromReader` constructor
      or `toWriter`/`writeToJson` method).
    - Fallback to standard `json_serializable` for nested objects if they don't
      support streaming.
    - Generate code that uses `JsonReader` and `JsonWriter` directly.
    - Example generated code showing how fields and lists/arrays are handled:
      ```dart
      Person _$PersonFromJson(JsonReader reader) {
        reader.beginObject();
        String? name;
        int? age;
        List<String>? tags;
        while (reader.hasNext()) {
          final key = reader.nextName();
          switch (key) {
            case 'name': name = reader.nextString();
            case 'age': age = reader.nextNumber().toInt();
            case 'tags':
              reader.beginArray();
              tags = [];
              while (reader.hasNext()) {
                tags.add(reader.nextString());
              }
              reader.endArray();
            default: reader.skipValue();
          }
        }
        reader.endObject();
        return Person(name: name!, age: age!, tags: tags!);
      }

      void _$PersonToJson(Person instance, JsonWriter writer) {
        writer.beginObject();
        writer.name('name');
        writer.writeString(instance.name);
        writer.name('age');
        writer.writeNumber(instance.age);
        writer.name('tags');
        writer.beginArray();
        for (final tag in instance.tags) {
          writer.writeString(tag);
        }
        writer.endArray();
        writer.endObject();
      }
      ```


## After POC

### Direct UTF-8 Parsing
We will start by decoding bytes to strings first for simplicity. Since both
approaches will implement the `JsonReader` interface, transitioning to direct
UTF-8 parsing later will not be a breaking change for the generated code,
assuming we have robust test coverage for the initial implementation.
