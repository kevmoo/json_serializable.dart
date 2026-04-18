# Streaming JSON R/W Design Matrix

This document outlines the matrix of supported operations for the `json_rw` library, covering reading and writing across different data types and streaming models.

## The Matrix

### Reading (Parsing)
We want to support populating a custom class (e.g., `CustomClass`) from the following sources:

| Source | Model A: Pull (Callbacks) | Model B: Push (State Machine) | Status |
| :--- | :--- | :--- | :--- |
| **String** | Supported (via `JsonReader`) | Supported (via Builder) | Done |
| **Stream<String>** | Supported (via `ChunkedJsonReader`) | Supported (via `JsonBuilderTransformer`) | Done |
| **List<int> (Bytes)** | Supported (via `Utf8JsonReader`) | Supported (via Builder) | Done |
| **Stream<List<int>>** | Supported (via Stream pipe) | Supported (via Stream pipe) | Done |

### Writing (Serialization)
We want to support writing a custom class to the following targets:

| Target | Compact Mode | Pretty Mode (Indented) | Status |
| :--- | :--- | :--- | :--- |
| **String** | Supported (`StringJsonWriter`) | Supported (`PrettyStringJsonWriter`) | Done |
| **Stream<String>** | Supported (via Sink) | Supported (via Sink) | Done |
| **List<int> (Bytes)** | Supported (`BytesJsonWriter`) | Supported (`BytesJsonWriter`) | Done |
| **Stream<List<int>>** | Supported (via Stream pipe) | Supported (via Stream pipe) | Done |

## The Converter Model

To fill the gaps for `List<int>` and `Stream<List<int>>`, we adopted the `Converter` model from `dart:convert`.

### For Reading:
Create `JsonReaderConverter<T>` implementing `Converter<String, T>`.
- **Bytes**: `Utf8Decoder().fuse(JsonReaderConverter<T>()).convert(bytes)`
- **Stream**: `stream.transform(Utf8Decoder()).transform(JsonReaderConverter<T>())`

### For Writing:
Create `JsonWriterConverter<T>` implementing `Converter<T, String>`.
- **Bytes**: `JsonWriterConverter<T>().fuse(Utf8Encoder()).convert(obj)`
- **Stream**: `stream.transform(JsonWriterConverter<T>()).transform(Utf8Encoder())`

By specializing the `fuse` method for `Utf8Encoder`/`Utf8Decoder`, we can bypass intermediate string allocations and use optimized byte-based writers/readers internally.

## Reference: dart:convert Matrix
For comparison, here is how the standard `dart:convert` library handles these cases (operating on dynamic `Map`/`List` rather than custom classes):

| Operation | Source/Target | Desugared API | Sugar | Output/Input Type |
| :--- | :--- | :--- | :--- | :--- |
| **Read** | String | `JsonDecoder().convert(str)` | `json.decode(str)` | `dynamic` |
| **Read** | Stream<String> | `JsonDecoder().startChunkedConversion(...)` | `json.decoder...` | `ChunkedConversionSink` |
| **Read** | List<int> (Bytes) | `Utf8Decoder().fuse(JsonDecoder()).convert(bytes)` | `utf8.decode` + `json.decode` | `dynamic` |
| **Read** | Stream<List<int>> | `stream.transform(Utf8Decoder()).transform(JsonDecoder())` | `stream.transform...` | `Stream<dynamic>` |
| **Write** | Object | `JsonEncoder().convert(obj)` | `json.encode(obj)` | `String` |
| **Write** | Object (Pretty) | `JsonEncoder.withIndent('  ').convert(obj)` | `JsonEncoder...` | `String` |
| **Write** | Object -> Bytes | `JsonEncoder().fuse(Utf8Encoder()).convert(obj)` | `json.encoder.fuse...` | `List<int>` |
| **Write** | Object (Pretty) -> Bytes | `JsonEncoder.withIndent('  ').fuse(Utf8Encoder()).convert(obj)` | `...` | `List<int>` |

## Design Questions

1. **Byte Support (List<int>)**:
   - For reading, do we want to decode UTF-8 on the fly, or scan bytes directly?
   - For writing, do we want to write UTF-8 bytes directly to avoid string allocations?
2. **Pretty Writing for Bytes**:
   - We want to support a "pretty writer for bytes". This means we need to handle indentation while outputting a byte stream.
3. **Unification**:
   - Can we use a single core engine for both String and Byte targets, similar to how the Dart SDK uses specialized sinks in `JsonEncoder`?

## Next Steps
- Decide on the priority of the gaps.
- Plan the API for byte-based reading/writing.
