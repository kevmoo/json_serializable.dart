import 'dart:convert';
import 'dart:io';
import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.builder.dart';
import 'shared.dart';

class JsonRwFilePushBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonRwFilePushBenchmark() : super('json_rw_file_push');

  @override
  Future<void> setup() async {
    _tempDir = Directory.systemTemp.createTempSync('json_rw_bench');
    _filePath = '${_tempDir!.path}/large.json';
    await File(_filePath!).writeAsString(largeJsonString);
  }

  @override
  Future<void> teardown() async {
    await _tempDir?.delete(recursive: true);
  }

  @override
  Future<void> runImpl() async {
    final reader = ChunkedJsonReader();
    final builder = ComplexObjectBuilder();

    await for (final chunk in File(_filePath!).openRead()) {
      reader.addChunk(utf8.decode(chunk));
      builder.hydrate(reader);
    }

    builder.build();
  }
}
