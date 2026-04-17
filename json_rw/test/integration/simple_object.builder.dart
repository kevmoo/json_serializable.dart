import 'package:json_rw/json_rw.dart';
import 'simple_object.dart';

class SimpleObjectBuilder implements ResumableBuilder<SimpleObject> {
  int? value;
  int state = 0;

  @override
  bool hydrate(ChunkedJsonReader reader) {
    try {
      while (true) {
        switch (state) {
          case 0:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            reader.beginObject();
            state = 1;
          case 1:
            if (!reader.hasNext()) {
              final token = reader.peek();
              if (token == JsonToken.endObject) {
                reader.endObject();
                return true;
              }
              return false; // need more data
            }
            final key = reader.nextName();
            if (key == 'value') {
              state = 2;
            } else {
              reader.skipValue();
            }
          case 2:
            if (reader.peek() == JsonToken.eof) {
              return false; // need more data
            }
            value = reader.nextNumber().toInt();
            state = 1;
        }
      }
    } catch (e) {
      if (e is FormatException && e.toString().contains('not ready')) {
        return false;
      }
      rethrow;
    }
  }

  @override
  SimpleObject build() => SimpleObject(value!);
}
