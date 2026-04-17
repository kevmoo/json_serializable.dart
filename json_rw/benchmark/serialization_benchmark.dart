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
  'json_serializable': () => JsonSerializableBenchmark().report(),
  'json_rw': () => JsonRwBenchmark().report(),
  'json_serializable_utf8': () => JsonSerializableUtf8Benchmark().report(),
  'json_rw_utf8': () => JsonRwUtf8Benchmark().report(),
  'json_serializable_read': () => JsonSerializableReadBenchmark().report(),
  'json_rw_read': () => JsonRwReadBenchmark().report(),
  'json_serializable_utf8_read': () =>
      JsonSerializableUtf8ReadBenchmark().report(),
  'json_rw_utf8_read': () => JsonRwUtf8ReadBenchmark().report(),
};
