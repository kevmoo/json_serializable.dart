import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

import 'complex_object.dart';
import 'simple_object.dart';

void main() {
  group('ComplexObject Integration', () {
    test('round-trip', () {
      final obj = ComplexObject(
        name: 'John',
        age: 30,
        objects: [SimpleObject(1), SimpleObject(2)],
        map: {'key1': 'value1', 'key2': 'value2'},
      );

      // Serialize
      final sb = StringBuffer();
      obj.toWriter(JsonWriter(sb));
      final jsonStr = sb.toString();

      // Deserialize
      final reader = JsonReader.fromString(jsonStr);
      final decoded = ComplexObject.fromReader(reader);

      check(decoded).equals(obj);
    });
  });
}
