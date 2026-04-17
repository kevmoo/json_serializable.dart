import 'base_json_writer.dart';
import 'json_writer.dart';

class StringJsonWriter extends BaseJsonWriter {
  final StringSink _sink;

  StringJsonWriter(this._sink, [IndentType? indentType, int? indentCount])
    : super(indentType, indentCount);

  @override
  void writeRawString(String s) {
    _sink.write(s);
  }

  @override
  void writeRawChar(int c) {
    _sink.writeCharCode(c);
  }
}
