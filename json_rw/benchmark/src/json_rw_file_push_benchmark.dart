import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.builder.dart';
import 'shared.dart';

class JsonRwFilePushBenchmark extends JsonBenchmarkBase {
  List<String>? _chunks;

  JsonRwFilePushBenchmark() : super('json_rw_file_push');

  @override
  void setup() {
    _chunks = <String>[];
    const chunkSize = 1024;
    for (var i = 0; i < largeJsonString.length; i += chunkSize) {
      final end = i + chunkSize;
      _chunks!.add(largeJsonString.substring(
          i, end < largeJsonString.length ? end : largeJsonString.length));
    }
  }

  @override
  void runImpl() {
    final reader = ChunkedJsonReader();
    final builder = ComplexObjectBuilder();

    for (final chunk in _chunks!) {
      reader.addChunk(chunk);
      builder.hydrate(reader);
    }

    builder.build();
  }
}
