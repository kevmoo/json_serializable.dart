import 'dart:convert';
import 'byte_chunked_json_reader.dart';
import 'resumable_builder.dart';

/// A [Converter] that decodes a stream of JSON bytes into objects of type [T].
class ByteJsonReaderConverter<T> extends Converter<List<int>, T> {
  final ResumableBuilder<T> Function() _createBuilder;

  /// Creates a [ByteJsonReaderConverter] using the provided factory.
  const ByteJsonReaderConverter(this._createBuilder);

  @override
  T convert(List<int> input) {
    final reader = ByteChunkedJsonReader()..addChunk(input);
    return _createBuilder().parse(reader);
  }

  @override
  ChunkedConversionSink<List<int>> startChunkedConversion(Sink<T> sink) =>
      _ByteJsonReaderSink<T>(sink, _createBuilder);
}

class _ByteJsonReaderSink<T> implements ChunkedConversionSink<List<int>> {
  final Sink<T> _sink;
  final ResumableBuilder<T> Function() _createBuilder;
  final ByteChunkedJsonReader _reader = ByteChunkedJsonReader();
  ResumableBuilder<T>? _builder;

  _ByteJsonReaderSink(this._sink, this._createBuilder);

  @override
  void add(List<int> chunk) {
    _reader.addChunk(chunk);
    _builder ??= _createBuilder();

    while (true) {
      if (_builder!.hydrate(_reader)) {
        _sink.add(_builder!.build());
        _builder = _createBuilder();
        continue;
      }
      break;
    }
  }

  @override
  void close() {
    _sink.close();
  }
}
