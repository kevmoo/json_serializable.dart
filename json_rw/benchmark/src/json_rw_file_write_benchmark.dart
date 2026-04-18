import 'dart:io';
import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwFileWriteBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonRwFileWriteBenchmark() : super('json_rw_file_write');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.write,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.file,
    impl: BenchmarkImpl.jsonRw,
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
        .transform(
          NewJsonUtf8Converter<ComplexObject>(
            (ComplexObject obj, writer) => obj.toWriter(writer),
          ),
        )
        .pipe(file.openWrite());
  }
}
