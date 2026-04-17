import 'dart:io';
import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwByteFilePushBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonRwByteFilePushBenchmark() : super('json_rw_byte_file_push');

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
    await File(_filePath!)
        .openRead()
        .transform(
          const ByteJsonReaderConverter<ComplexObject>(ComplexObject.builder),
        )
        .single;
  }
}
