import 'dart:convert';
import 'dart:typed_data';
import 'base_json_writer.dart';
import 'json_writer.dart';

class BytesJsonWriter extends BaseJsonWriter {
  final BytesBuilder _builder;

  BytesJsonWriter(this._builder, [IndentType? indentType, int? indentCount])
      : super(indentType, indentCount);

  @override
  void writeRawString(String s) {
    _builder.add(utf8.encode(s));
  }

  @override
  void writeRawChar(int c) {
    _builder.addByte(c);
  }
}
