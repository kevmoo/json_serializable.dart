import 'dart:convert';
import '../../test/integration/complex_object.dart';
import 'shared.dart';

class JsonSerializableChunkedReadBenchmark extends JsonBenchmarkBase {
  const JsonSerializableChunkedReadBenchmark()
    : super('json_serializable_chunked_read');

  @override
  BenchmarkMetadata get metadata => (
    op: BenchmarkOp.read,
    size: BenchmarkSize.large,
    format: BenchmarkFormat.chunked,
    impl: BenchmarkImpl.jsonSerializable,
  );

  @override
  void runImpl() {
    Map<String, dynamic>? resultMap;

    final outputSink = ChunkedConversionSink<Object?>.withCallback((objects) {
      resultMap = objects.first as Map<String, dynamic>;
    });
    final inputSink = json.decoder.startChunkedConversion(outputSink);

    const chunkSize = 1024;
    for (var i = 0; i < largeJsonString.length; i += chunkSize) {
      final end = i + chunkSize;
      final chunk = largeJsonString.substring(
        i,
        end < largeJsonString.length ? end : largeJsonString.length,
      );
      inputSink.add(chunk);
    }
    inputSink.close();

    ComplexObject.fromJson(resultMap!);
  }
}
