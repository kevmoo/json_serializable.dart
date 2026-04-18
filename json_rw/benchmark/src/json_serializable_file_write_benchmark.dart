import 'dart:convert';
import 'dart:io';
import 'shared.dart';

class JsonSerializableFileWriteBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonSerializableFileWriteBenchmark() : super('json_serializable_file_write');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.file,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

  @override
  Future<void> setup() async {
    _tempDir = Directory.systemTemp.createTempSync('json_rw_bench');
    _filePath = '${_tempDir!.path}/large.json';
  }

  @override
  Future<void> teardown() async {
    final file = File(_filePath!);
    if (!file.existsSync()) {
      throw StateError('File does not exist!');
    }
    if (file.lengthSync() == 0) {
      throw StateError('File is empty!');
    }
    await _tempDir?.delete(recursive: true);
  }

  @override
  Future<void> runImpl() async {
    final file = File(_filePath!);

    await getComplexObjectStream()
        .cast<Object?>()
        .transform(JsonUtf8Encoder())
        .pipe(file.openWrite());
  }
}
