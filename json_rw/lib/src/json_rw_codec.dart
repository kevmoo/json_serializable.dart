import 'dart:convert';
import 'json_reader_converter.dart';
import 'json_writer.dart';
import 'json_writer_converter.dart';
import 'resumable_builder.dart';

class JsonRwCodec<T> extends Codec<T, String> {
  final void Function(T object, JsonWriter writer) _write;
  final ResumableBuilder<T> Function() _createBuilder;
  final IndentType? _indentType;
  final int? _indentCount;

  const JsonRwCodec({
    required void Function(T object, JsonWriter writer) write,
    required ResumableBuilder<T> Function() builder,
    IndentType? indentType,
    int? indentCount,
  })  : _write = write,
        _createBuilder = builder,
        _indentType = indentType,
        _indentCount = indentCount;

  @override
  JsonWriterConverter<T> get encoder => JsonWriterConverter<T>(
        _write,
        indentType: _indentType,
        indentCount: _indentCount,
      );

  @override
  JsonReaderConverter<T> get decoder => JsonReaderConverter<T>(_createBuilder);
}
