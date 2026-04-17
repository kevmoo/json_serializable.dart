import 'dart:convert';
import 'dart:io';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

void main() async {
  // Start the benchmark process
  final process = await Process.start(
    Platform.resolvedExecutable,
    [
      '--enable-vm-service',
      'benchmark/serialization_benchmark.dart',
      'json_serializable_utf8', // Run a specific benchmark
    ],
    environment: {'DART_PROFILING': 'true'},
  );

  // Read stdout to find the VM Service URI
  final lines = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  String? vmServiceUri;
  VmService? service;
  String? isolateId;

  AllocationProfile? profile1;
  AllocationProfile? profile2;

  print('Processing output...');
  await for (final line in lines) {
    print('STDOUT: $line');

    if (line.contains('The Dart VM service is listening on') &&
        vmServiceUri == null) {
      final parts = line.split('The Dart VM service is listening on');
      vmServiceUri = parts[1].trim();

      final wsUri = Uri.parse(
        vmServiceUri,
      ).replace(scheme: 'ws', path: '${Uri.parse(vmServiceUri).path}ws');
      print('Connecting to VM Service at $wsUri');
      service = await vmServiceConnectUri(wsUri.toString());

      final vm = await service.getVM();
      isolateId = vm.isolates!.first.id!;
    }

    if (line.contains('READY') &&
        profile1 == null &&
        service != null &&
        isolateId != null) {
      print('Fetching initial allocation profile...');
      profile1 = await service.getAllocationProfile(isolateId);

      print('Signaling benchmark to start...');
      process.stdin.writeln();
    }

    if (line.contains('DONE') &&
        profile1 != null &&
        service != null &&
        isolateId != null) {
      print('Fetching final allocation profile...');
      profile2 = await service.getAllocationProfile(isolateId);

      print('Signaling benchmark to exit...');
      process.stdin.writeln();
      break;
    }
  }

  if (profile1 == null || profile2 == null) {
    print('Failed to capture profiles');
    process.kill();
    return;
  }

  print('\n--- Allocation Results ---');
  final map1 = {for (final m in profile1.members!) m.classRef!.name!: m};

  for (final member2 in profile2.members!) {
    final name = member2.classRef!.name!;
    final member1 = map1[name];
    final diffInstances =
        member2.instancesAccumulated! - (member1?.instancesAccumulated ?? 0);
    final diffSize = member2.accumulatedSize! - (member1?.accumulatedSize ?? 0);

    if (diffInstances > 1000) {
      print('$name: $diffInstances instances, $diffSize bytes');
    }
  }

  process.kill();
  exit(0);
}
