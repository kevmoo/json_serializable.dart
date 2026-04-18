# JSON RW Architecture Overview

This document outlines the architecture of the `json_rw` library after the high-performance streaming refactor.

The library provides two parallel layers of APIs:
1.  **Low-Level Imperative APIs**: Direct, granular control over reading and writing JSON tokens.
2.  **High-Level Declarative Converters**: Idiomatic Dart `Converter` and `StreamTransformer` implementations that integrate with `dart:convert`.

---

## 1. Low-Level Imperative APIs

These APIs are designed for maximum performance and minimal memory allocation. They do not build intermediate `Map` or `List` structures unless explicitly requested.

### Writing (`JsonWriter`)

The `JsonWriter` interface provides a push-based API to generate JSON.

*   **`JsonWriter` (Abstract Factory)**: Dispatches to concrete implementations based on the output type and options.
*   **`BaseJsonWriter`**: An abstract base class that handles the JSON state machine (brackets, commas, colons), string escaping, and indentation logic. It delegates actual character/string output to subclasses.
*   **`StringJsonWriter`**: Extends `BaseJsonWriter` to write directly to a `StringSink`.
*   **`BytesJsonWriter`**: Extends `BaseJsonWriter` to write directly to a `BytesBuilder` (from `dart:typed_data`), producing UTF-8 bytes without intermediate string allocations.

### Reading (`JsonReader`)

The `JsonReader` interface provides a pull-based API to consume JSON tokens.

*   **`StringJsonReader`**: Reads JSON from a flat `String`.
*   **`Utf8JsonReader`**: Reads JSON directly from a `List<int>` of UTF-8 bytes.
*   **`ChunkedLexer`**: A low-level tokenizer designed to handle fragmented input (e.g., reading from a stream). It can resume scanning across chunk boundaries.
*   **`ChunkedJsonReader`**: Sits on top of `ChunkedLexer` to provide a high-level reader interface over fragmented inputs (Strings or Bytes).

---

## 2. High-Level Converters

These classes implement `Converter` from `dart:convert` and allow the library to be used in standard Dart streams and pipelines. They wrap the low-level APIs to provide a familiar developer experience.

### `JsonWriterConverter<T>`

Converts domain objects of type `T` to JSON.

*   Requires a `void Function(T object, JsonWriter writer)` callback to define how the object should be written.
*   **Sync Usage**: `converter.convert(object)` returns a `String`.
*   **Streaming Usage**: `stream.transform(converter)` transforms a stream of objects into a stream of JSON strings.
*   **Fused Usage**: `converter.fuse(utf8.encoder)` returns a specialized converter that skips intermediate string allocations and writes UTF-8 bytes directly to a `BytesBuilder`.

### `JsonReaderConverter<T>`

Converts JSON strings or bytes into domain objects of type `T`.

*   Requires a builder function that consumes a `JsonReader` and returns an instance of `T`.
*   Handles both synchronous parsing and asynchronous stream hydration.
*   Automatically detects whether the input is chunked and manages the state machines required to resume parsing across chunks.

---

## Summary Matrix

| Feature | String Source | Byte Source | String Output | Byte Output |
| :--- | :--- | :--- | :--- | :--- |
| **Imperative** | `StringJsonReader` | `Utf8JsonReader` | `StringJsonWriter` | `BytesJsonWriter` |
| **Streaming** | `ChunkedJsonReader` | `ChunkedJsonReader` | `JsonWriterConverter` | `JsonWriterConverter.fuse` |
| **Indentation** | N/A | N/A | Supported | Supported |
