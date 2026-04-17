import 'dart:convert';
import 'chunked_json_reader.dart';
import 'resumable_builder.dart';

class JsonReaderConverter<T> extends Converter<String, T> {
  final ResumableBuilder<T> Function() _createBuilder;

  const JsonReaderConverter(this._createBuilder);

  @override
  T convert(String input) {
    final reader = ChunkedJsonReader()..addChunk(input);
    return _createBuilder().parse(reader);
  }

  @override
  ChunkedConversionSink<String> startChunkedConversion(Sink<T> sink) =>
      _JsonReaderSink<T>(sink, _createBuilder);
}

class _JsonReaderSink<T> implements ChunkedConversionSink<String> {
  final Sink<T> _sink;
  final ResumableBuilder<T> Function() _createBuilder;
  final ChunkedJsonReader _reader = ChunkedJsonReader();
  ResumableBuilder<T>? _builder;

  _JsonReaderSink(this._sink, this._createBuilder);

  @override
  void add(String chunk) {
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
