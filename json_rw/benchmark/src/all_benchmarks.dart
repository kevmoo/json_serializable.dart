import 'json_rw_benchmark.dart';
import 'json_rw_byte_file_push_benchmark.dart';
import 'json_rw_chunked_read_benchmark.dart';
import 'json_rw_file_pull_benchmark.dart';
import 'json_rw_file_push_benchmark.dart';
import 'json_rw_read_benchmark.dart';
import 'json_rw_utf8_benchmark.dart';
import 'json_rw_utf8_read_benchmark.dart';
import 'json_serializable_benchmark.dart';
import 'json_serializable_chunked_read_benchmark.dart';
import 'json_serializable_file_benchmark.dart';
import 'json_serializable_read_benchmark.dart';
import 'json_serializable_utf8_benchmark.dart';
import 'json_serializable_utf8_read_benchmark.dart';
import 'shared.dart';

/// The set of all benchmarks in the suite.
final Set<DescribedBenchmark> benchmarks = {
  const JsonRwBenchmark(),
  const JsonRwSmallBenchmark(),
  JsonRwFileByteJsonReaderConverterBenchmark(),
  const JsonRwChunkedReadBenchmark(),
  const JsonRwChunkedReadSmallBenchmark(),
  JsonRwFileChunkedJsonReaderBenchmark(),
  JsonRwFileJsonReaderConverterBenchmark(),
  const JsonRwReadBenchmark(),
  const JsonRwReadSmallBenchmark(),
  const JsonRwUtf8Benchmark(),
  const JsonRwUtf8SmallBenchmark(),
  const JsonRwUtf8ReadBenchmark(),
  const JsonRwUtf8ReadSmallBenchmark(),
  const JsonSerializableBenchmark(),
  const JsonSerializableSmallBenchmark(),
  const JsonSerializableChunkedReadBenchmark(),
  JsonSerializableFileBenchmark(), // Not const
  const JsonSerializableReadBenchmark(),
  const JsonSerializableReadSmallBenchmark(),
  const JsonSerializableUtf8Benchmark(),
  const JsonSerializableUtf8SmallBenchmark(),
  const JsonSerializableUtf8ReadBenchmark(),
  const JsonSerializableUtf8ReadSmallBenchmark(),
};
