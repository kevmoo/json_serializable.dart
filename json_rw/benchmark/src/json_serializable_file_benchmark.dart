import 'dart:convert';
import 'dart:io';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableFileBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonSerializableFileBenchmark() : super('json_serializable_file');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.file,
    impl: BenchmarkImpl.jsonSerializable,
    variant: null,
  );

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
    final map =
        await File(
              _filePath!,
            ).openRead().transform(utf8.decoder).transform(json.decoder).single
            as Map<String, dynamic>;

    ComplexObject.fromJson(map);
  }
}
