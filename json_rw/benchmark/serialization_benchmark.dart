import 'dart:async';
import 'dart:io';

import 'src/all_benchmarks.dart';
import 'src/shared.dart';

Future<void> main(List<String> arguments) async {
  final runAll = arguments.isEmpty || arguments.contains('all');
  final profiling = Platform.environment['DART_PROFILING'] == 'true';

  final iterator = profiling ? StreamIterator(stdin) : null;

  if (profiling) {
    print('READY');
    await iterator!.moveNext();
  }

  final results = <DescribedBenchmark, double>{};

  for (final benchmark in benchmarks) {
    if (runAll || arguments.contains(benchmark.name)) {
      double time;
      if (benchmark is AsyncJsonBenchmarkBase) {
        time = await benchmark.measure();
      } else if (benchmark is JsonBenchmarkBase) {
        time = benchmark.measure();
      } else {
        continue;
      }
      results[benchmark] = time;
      print('${benchmark.name}(RunTime): $time us.');
    }
  }

  if (results.isEmpty) {
    print('No benchmarks matched the arguments: $arguments');
    print('Available benchmarks: ${benchmarks.map((b) => b.name).join(', ')}');
  }

  if (profiling) {
    print('DONE');
    await iterator!.moveNext();
  }
}
