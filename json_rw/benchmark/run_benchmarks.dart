import 'dart:io';

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
| Mode | Size | Format | `json_serializable` | `json_rw` | Winner (% faster) |
| :--- | :--- | :--- | :--- | :--- | :--- |''');

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

    String winner;
    double percent;
    if (baseMedian < rwMedian) {
      winner = '`json_serializable`';
      percent = (rwMedian / baseMedian - 1) * 100;
    } else {
      winner = '`json_rw`';
      percent = (baseMedian / rwMedian - 1) * 100;
    }

    final baseStr = baseMedian.toStringAsFixed(2);
    final rwStr = rwMedian.toStringAsFixed(2);
    final percentStr = percent.toStringAsFixed(1);
    final line =
        '| $mode | $size | $format | $baseStr µs | $rwStr µs | '
        '$winner ($percentStr% faster) |';
    print(line);
  }

  compare('Write', 'Large', 'String', 'json_serializable', 'json_rw');
  compare('Write', 'Large', 'UTF-8', 'json_serializable_utf8', 'json_rw_utf8');
  compare('Read', 'Large', 'String', 'json_serializable_read', 'json_rw_read');
  compare(
    'Read',
    'Large',
    'UTF-8',
    'json_serializable_utf8_read',
    'json_rw_utf8_read',
  );

  compare(
    'Write',
    'Small',
    'String',
    'json_serializable_small',
    'json_rw_small',
  );
  compare(
    'Write',
    'Small',
    'UTF-8',
    'json_serializable_utf8_small',
    'json_rw_utf8_small',
  );
  compare(
    'Read',
    'Small',
    'String',
    'json_serializable_read_small',
    'json_rw_read_small',
  );
  compare(
    'Read',
    'Small',
    'UTF-8',
    'json_serializable_utf8_read_small',
    'json_rw_utf8_read_small',
  );
}
