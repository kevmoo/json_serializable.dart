import 'chunked_json_reader.dart';

abstract class ResumableBuilder<T> {
  bool hydrate(ChunkedJsonReader reader);
  T build();
}
