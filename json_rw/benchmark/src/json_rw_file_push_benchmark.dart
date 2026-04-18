import 'dart:convert';
import 'dart:io';

import 'package:json_rw/json_rw.dart';

import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwFileJsonReaderConverterBenchmark extends AsyncJsonBenchmarkBase {
  Directory? _tempDir;
  String? _filePath;

  JsonRwFileJsonReaderConverterBenchmark()
    : super('json_rw_file_json_reader_converter');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.file,
    impl: BenchmarkImpl.jsonRw,
    variant: 'JsonReaderConverter',
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
    await File(_filePath!)
        .openRead()
        .transform(utf8.decoder)
        .transform(
          const JsonReaderConverter<ComplexObject>(ComplexObject.builder),
        )
        .single;
  }
}
