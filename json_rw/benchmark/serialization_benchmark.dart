import 'dart:async';
import 'dart:io';

import 'src/json_rw_benchmark.dart';
import 'src/json_rw_byte_file_push_benchmark.dart';
import 'src/json_rw_chunked_read_benchmark.dart';
import 'src/json_rw_file_pull_benchmark.dart';
import 'src/json_rw_file_push_benchmark.dart';
import 'src/json_rw_read_benchmark.dart';
import 'src/json_rw_utf8_benchmark.dart';
import 'src/json_rw_utf8_read_benchmark.dart';
import 'src/json_serializable_benchmark.dart';
import 'src/json_serializable_chunked_read_benchmark.dart';
import 'src/json_serializable_file_benchmark.dart';
import 'src/json_serializable_read_benchmark.dart';
import 'src/json_serializable_utf8_benchmark.dart';
import 'src/json_serializable_utf8_read_benchmark.dart';

Future<void> main(List<String> arguments) async {
  final runAll = arguments.isEmpty || arguments.contains('all');
  final profiling = Platform.environment['DART_PROFILING'] == 'true';

  final iterator = profiling ? StreamIterator(stdin) : null;

  if (profiling) {
    print('READY');
    await iterator!.moveNext();
  }

  var executed = 0;
  for (final entry in _benchmarks.entries) {
    if (runAll || arguments.contains(entry.key)) {
      await entry.value();
      executed++;
    }
  }

  if (executed == 0) {
    print('No benchmarks matched the arguments: $arguments');
    print('Available benchmarks: ${_benchmarks.keys.join(', ')}');
  }

  if (profiling) {
    print('DONE');
    await iterator!.moveNext();
  }
}

final _benchmarks = <String, FutureOr<void> Function()>{
  'json_serializable': const JsonSerializableBenchmark().report,
  'json_rw': const JsonRwBenchmark().report,
  'json_serializable_utf8': const JsonSerializableUtf8Benchmark().report,
  'json_rw_utf8': const JsonRwUtf8Benchmark().report,
  'json_serializable_read': const JsonSerializableReadBenchmark().report,
  'json_rw_read': const JsonRwReadBenchmark().report,
  'json_rw_chunked_read': const JsonRwChunkedReadBenchmark().report,
  'json_serializable_chunked_read':
      const JsonSerializableChunkedReadBenchmark().report,
  'json_serializable_utf8_read':
      const JsonSerializableUtf8ReadBenchmark().report,
  'json_rw_utf8_read': const JsonRwUtf8ReadBenchmark().report,

  'json_serializable_small': const JsonSerializableSmallBenchmark().report,
  'json_rw_small': const JsonRwSmallBenchmark().report,
  'json_serializable_utf8_small':
      const JsonSerializableUtf8SmallBenchmark().report,
  'json_rw_utf8_small': const JsonRwUtf8SmallBenchmark().report,
  'json_serializable_read_small':
      const JsonSerializableReadSmallBenchmark().report,
  'json_rw_read_small': const JsonRwReadSmallBenchmark().report,
  'json_rw_chunked_read_small': const JsonRwChunkedReadSmallBenchmark().report,
  'json_serializable_utf8_read_small':
      const JsonSerializableUtf8ReadSmallBenchmark().report,
  'json_rw_utf8_read_small': const JsonRwUtf8ReadSmallBenchmark().report,
  'json_rw_file_pull': () => JsonRwFilePullBenchmark().report(),
  'json_rw_file_push': () => JsonRwFilePushBenchmark().report(),
  'json_rw_byte_file_push': () => JsonRwByteFilePushBenchmark().report(),
  'json_serializable_file': () => JsonSerializableFileBenchmark().report(),
};
