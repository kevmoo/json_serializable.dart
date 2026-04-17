import 'dart:convert';
import 'dart:io';
import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwFilePullBenchmark extends JsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonRwFilePullBenchmark() : super('json_rw_file_pull');

  @override
  void setup() {
    _tempDir = Directory.systemTemp.createTempSync('json_rw_bench');
    _filePath = '${_tempDir!.path}/large.json';
    File(_filePath!).writeAsStringSync(largeJsonString);
  }

  @override
  void teardown() {
    _tempDir?.deleteSync(recursive: true);
  }

  @override
  void runImpl() {
    final file = File(_filePath!).openSync();
    final reader = ChunkedJsonReader(
      onChunkNeeded: () {
        final bytes = file.readSync(1024);
        if (bytes.isEmpty) return null;
        return utf8.decode(bytes);
      },
    );

    try {
      ComplexObject.fromReader(reader);
    } finally {
      file.closeSync();
    }
  }
}
