import 'dart:async';
import 'dart:io';

import 'src/all_benchmarks.dart';

Future<void> main(List<String> arguments) async {
  final runAll = arguments.isEmpty || arguments.contains('all');
  final profiling = Platform.environment['DART_PROFILING'] == 'true';

  final iterator = profiling ? StreamIterator(stdin) : null;

  if (profiling) {
    print('READY');
    await iterator!.moveNext();
  }

  var executed = 0;
  for (final benchmark in benchmarks) {
    if (runAll || arguments.contains(benchmark.name)) {
      await benchmark.report();
      executed++;
    }
  }

  if (executed == 0) {
    print('No benchmarks matched the arguments: $arguments');
    print('Available benchmarks: ${benchmarks.map((b) => b.name).join(', ')}');
  }

  if (profiling) {
    print('DONE');
    await iterator!.moveNext();
  }
}
