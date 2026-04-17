import 'dart:convert';
import 'dart:typed_data';
import 'json_writer.dart';

class JsonWriterConverter<T> extends Converter<T, String> {
  final void Function(T object, JsonWriter writer) _write;
  final IndentType? _indentType;
  final int? _indentCount;

  JsonWriterConverter(this._write, {IndentType? indentType, int? indentCount})
      : _indentType = indentType,
        _indentCount = indentCount;

  @override
  String convert(T input) {
    final sb = StringBuffer();
    final writer = JsonWriter(
      sb,
      indentType: _indentType,
      indentCount: _indentCount,
    );
    _write(input, writer);
    return sb.toString();
  }

  @override
  ChunkedConversionSink<T> startChunkedConversion(
    Sink<String> sink,
  ) => _JsonWriterSink<T>(sink, _write, _indentType, _indentCount);

  @override
  Converter<T, R> fuse<R>(Converter<String, R> other) {
    if (other is Utf8Encoder) {
      return _FusedBytesConverter<T>(_write, _indentType)
          as Converter<T, R>;
    }
    return super.fuse(other);
  }
}

class _JsonWriterSink<T> implements ChunkedConversionSink<T> {
  final Sink<String> _sink;
  final void Function(T object, JsonWriter writer) _write;
  final IndentType? _indentType;
  final int? _indentCount;

  _JsonWriterSink(this._sink, this._write, this._indentType, this._indentCount);

  @override
  void add(T chunk) {
    final sb = StringBuffer();
    final writer = JsonWriter(
      sb,
      indentType: _indentType,
      indentCount: _indentCount,
    );
    _write(chunk, writer);
    _sink.add(sb.toString());
  }

  @override
  void close() {
    _sink.close();
  }
}

class _FusedBytesConverter<T> extends Converter<T, List<int>> {
  final void Function(T object, JsonWriter writer) _write;
  final IndentType? _indentType;

  _FusedBytesConverter(this._write, this._indentType);

  @override
  List<int> convert(T input) {
    final builder = BytesBuilder();
    final writer = JsonWriter.bytes(
      builder,
      indentType: _indentType,
    );
    _write(input, writer);
    return builder.toBytes();
  }

  @override
  ChunkedConversionSink<T> startChunkedConversion(
    Sink<List<int>> sink,
  ) => _JsonBytesWriterSink<T>(sink, _write, _indentType);
}

class _JsonBytesWriterSink<T> implements ChunkedConversionSink<T> {
  final Sink<List<int>> _sink;
  final void Function(T object, JsonWriter writer) _write;
  final IndentType? _indentType;

  _JsonBytesWriterSink(
    this._sink,
    this._write,
    this._indentType,
  );

  @override
  void add(T chunk) {
    final builder = BytesBuilder();
    final writer = JsonWriter.bytes(
      builder,
      indentType: _indentType,
    );
    _write(chunk, writer);
    _sink.add(builder.toBytes());
  }

  @override
  void close() {
    _sink.close();
  }
}
