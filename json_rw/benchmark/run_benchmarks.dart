import 'dart:io';

import 'src/all_benchmarks.dart';
import 'src/shared.dart';

String _capitalize(String s) =>
    s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

void main(List<String> arguments) async {
  // Ensure CWD is the json_rw directory
  final currentDirParts = Directory.current.path.split(Platform.pathSeparator);
  if (currentDirParts.isEmpty || currentDirParts.last != 'json_rw') {
    print('Error: This script must be run from the json_rw directory.');
    exitCode = 1;
    return;
  }

  final runs = arguments.isEmpty ? 5 : int.tryParse(arguments[0]) ?? 5;
  const exePath = '.dart_tool/serialization_benchmark.exe';

  final process = await Process.start(Platform.resolvedExecutable, [
    'compile',
    'exe',
    'benchmark/serialization_benchmark.dart',
    '-o',
    exePath,
  ], mode: ProcessStartMode.inheritStdio);

  final compileExitCode = await process.exitCode;
  if (compileExitCode != 0) {
    exitCode = compileExitCode;
    return;
  }

  print('Compiled benchmark to: $exePath');

  final results = <String, List<double>>{};

  print('Running benchmark $runs times...');
  for (var i = 0; i < runs; i++) {
    print('Run ${i + 1}/$runs...');
    final result = await Process.run(exePath, []);
    if (result.exitCode != 0) {
      print('Error running benchmark: ${result.stderr}');
      return;
    }

    final lines = result.stdout.toString().split('\n');
    for (final line in lines) {
      if (line.contains('(RunTime):')) {
        final parts = line.split('(RunTime):');
        final name = parts[0].trim();
        final valueStr = parts[1].replaceAll('us.', '').trim();
        final value = double.parse(valueStr);

        results.putIfAbsent(name, () => []).add(value);
      }
    }
  }

  print('''
\n
--- Benchmark Results Matrix (in µs) ---
| Benchmark | Median | Average | Fastest |
| :--- | :--- | :--- | :--- |''');

  final sortedKeys = results.keys.toList()..sort();
  for (final name in sortedKeys) {
    final values = results[name]!..sort();
    final fastest = values.first;
    final average = values.reduce((a, b) => a + b) / values.length;

    double median;
    if (values.length.isOdd) {
      median = values[values.length ~/ 2];
    } else {
      final v1 = values[values.length ~/ 2 - 1];
      final v2 = values[values.length ~/ 2];
      median = (v1 + v2) / 2;
    }

    final medianStr = median.toStringAsFixed(2);
    final averageStr = average.toStringAsFixed(2);
    final fastestStr = fastest.toStringAsFixed(2);
    print('| $name | $medianStr | $averageStr | $fastestStr |');
  }

  print('''
\n
--- A/B Comparison Matrix ---
| Mode | Size | Format | Old | New | Winner (% faster) |
| :--- | :--- | :--- | ---: | ---: | :--- |''');

  void compare(
    String mode,
    String size,
    String format,
    String baseName,
    String rwName,
  ) {
    final baseValues = results[baseName];
    final rwValues = results[rwName];

    if (baseValues == null || rwValues == null) return;

    baseValues.sort();
    rwValues.sort();

    final baseMedian = baseValues[baseValues.length ~/ 2];
    final rwMedian = rwValues[rwValues.length ~/ 2];

    String winnerStr;
    if (baseMedian < rwMedian) {
      final ratio = rwMedian / baseMedian;
      if (ratio >= 2.0) {
        winnerStr = '🐢 Old (**${ratio.toStringAsFixed(1)}x** faster)';
      } else {
        final percent = ((rwMedian - baseMedian) / baseMedian * 100)
            .toStringAsFixed(1);
        winnerStr = '🐢 Old ($percent% faster)';
      }
    } else {
      final ratio = baseMedian / rwMedian;
      if (ratio >= 2.0) {
        winnerStr = '🏆 New (**${ratio.toStringAsFixed(1)}x** faster)';
      } else {
        final percent = ((baseMedian - rwMedian) / rwMedian * 100)
            .toStringAsFixed(1);
        winnerStr = '🏆 New ($percent% faster)';
      }
    }

    final baseStr = baseMedian < rwMedian
        ? '**${baseMedian.toStringAsFixed(2)} µs**'
        : '${baseMedian.toStringAsFixed(2)} µs';
    final rwStr = rwMedian < baseMedian
        ? '**${rwMedian.toStringAsFixed(2)} µs**'
        : '${rwMedian.toStringAsFixed(2)} µs';

    final line = '| $mode | $size | $format | $baseStr | $rwStr | $winnerStr |';
    print(line);
  }

  // Find all json_rw benchmarks and pair them with the corresponding
  // json_serializable baseline
  final rwBenchmarks =
      benchmarks.where((b) => b.metadata.impl == BenchmarkImpl.jsonRw).toList()
        ..sort((a, b) {
          // Sort by op (write first), then size (large first), then format
          // (string first)
          final opCompare = b.metadata.op.index.compareTo(a.metadata.op.index);
          if (opCompare != 0) return opCompare;

          final sizeCompare = b.metadata.size.index.compareTo(
            a.metadata.size.index,
          );
          if (sizeCompare != 0) return sizeCompare;

          return a.metadata.format.index.compareTo(b.metadata.format.index);
        });

  for (final rw in rwBenchmarks) {
    DescribedBenchmark? baseMatch;
    for (final b in benchmarks) {
      if (b.metadata.impl == BenchmarkImpl.jsonSerializable &&
          b.metadata.op == rw.metadata.op &&
          b.metadata.size == rw.metadata.size &&
          b.metadata.format == rw.metadata.format) {
        baseMatch = b;
        break;
      }
    }

    if (baseMatch != null) {
      final formatStr = rw.metadata.variant != null
          ? '${_capitalize(rw.metadata.format.name)} (${rw.metadata.variant})'
          : _capitalize(rw.metadata.format.name);

      compare(
        _capitalize(rw.metadata.op.name),
        _capitalize(rw.metadata.size.name),
        formatStr,
        baseMatch.name,
        rw.name,
      );
    }
  }
}
