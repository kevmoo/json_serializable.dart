import 'dart:async';
import 'chunked_json_reader.dart';
import 'resumable_builder.dart';

class JsonBuilderTransformer<T> extends StreamTransformerBase<String, T> {
  final ResumableBuilder<T> _builder;

  JsonBuilderTransformer(this._builder);

  @override
  Stream<T> bind(Stream<String> stream) {
    final controller = StreamController<T>();
    final reader = ChunkedJsonReader();

    stream.listen(
      (chunk) {
        reader.addChunk(chunk);
        try {
          if (_builder.hydrate(reader)) {
            controller
              ..add(_builder.build())
              ..close();
          }
        } catch (e) {
          controller
            ..addError(e)
            ..close();
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller
            ..addError(const FormatException('Unexpected end of stream'))
            ..close();
        }
      },
      onError: (Object e, StackTrace st) {
        controller
          ..addError(e, st)
          ..close();
      },
      cancelOnError: true,
    );

    return controller.stream;
  }
}
