import 'src/json_rw_benchmark.dart';
import 'src/json_rw_read_benchmark.dart';
import 'src/json_rw_utf8_benchmark.dart';
import 'src/json_rw_utf8_read_benchmark.dart';
import 'src/json_serializable_benchmark.dart';
import 'src/json_serializable_read_benchmark.dart';
import 'src/json_serializable_utf8_benchmark.dart';
import 'src/json_serializable_utf8_read_benchmark.dart';

void main(List<String> arguments) {
  final runAll = arguments.isEmpty || arguments.contains('all');

  var executed = 0;
  benchmarks.forEach((name, run) {
    if (runAll || arguments.contains(name)) {
      run();
      executed++;
    }
  });

  if (executed == 0) {
    print('No benchmarks matched the arguments: $arguments');
    print('Available benchmarks: ${benchmarks.keys.join(', ')}');
  }
}

final benchmarks = <String, void Function()>{
  'json_serializable': const JsonSerializableBenchmark().report,
  'json_rw': const JsonRwBenchmark().report,
  'json_serializable_utf8': const JsonSerializableUtf8Benchmark().report,
  'json_rw_utf8': const JsonRwUtf8Benchmark().report,
  'json_serializable_read': const JsonSerializableReadBenchmark().report,
  'json_rw_read': const JsonRwReadBenchmark().report,
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
  'json_serializable_utf8_read_small':
      const JsonSerializableUtf8ReadSmallBenchmark().report,
  'json_rw_utf8_read_small': const JsonRwUtf8ReadSmallBenchmark().report,
};
