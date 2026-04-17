import 'dart:convert';
import 'json_writer.dart';
import 'utf8_json_writer.dart';

/// A [ChunkedConversionSink] that encodes objects of type [T] to UTF-8 JSON
/// bytes using a provided encoder function and a [JsonWriter].
class Utf8JsonWriterSink<T> implements ChunkedConversionSink<T> {
  final Utf8JsonWriter _writer;
  final void Function(T value, JsonWriter writer) _encoder;

  Utf8JsonWriterSink(this._writer, this._encoder);

  @override
  void add(T chunk) {
    _encoder(chunk, _writer);
  }

  @override
  void close() {
    // No-op.
  }
}
