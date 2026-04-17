import 'package:json_rw/json_rw.dart';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonRwChunkedReadBenchmark extends JsonBenchmarkBase {
  const JsonRwChunkedReadBenchmark() : super('json_rw_chunked_read');

  @override
  void runImpl() {
    final chunks = <String>[];
    const chunkSize = 1024;
    for (var i = 0; i < largeJsonString.length; i += chunkSize) {
      final end = i + chunkSize;
      chunks.add(largeJsonString.substring(
          i, end < largeJsonString.length ? end : largeJsonString.length));
    }

    var chunkIndex = 0;
    final reader = ChunkedJsonReader(
      onChunkNeeded: () {
        if (chunkIndex < chunks.length) {
          return chunks[chunkIndex++];
        }
        return null;
      },
    );
    ComplexObject.fromReader(reader);
  }
}

class JsonRwChunkedReadSmallBenchmark extends JsonBenchmarkBase {
  const JsonRwChunkedReadSmallBenchmark() : super('json_rw_chunked_read_small');

  @override
  void runImpl() {
    final reader = ChunkedJsonReader()..addChunk(smallJsonString);
    ComplexObject.fromReader(reader);
  }
}
