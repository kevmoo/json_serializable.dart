import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/json_rw.dart';
import 'package:test/scaffolding.dart';

import 'simple_object.dart';

void main() {
  group('SimpleObject Integration', () {
    test('round-trip', () {
      final obj = SimpleObject(42);

      // Serialize
      final sb = StringBuffer();
      obj.toWriter(JsonWriter(sb));
      final jsonStr = sb.toString();
      check(jsonStr).equals('{"value":42}');

      // Deserialize
      final reader = JsonReader.fromString(jsonStr);
      final decoded = SimpleObject.fromReader(reader);

      check(decoded).equals(obj);
    });

    test('compare behavior with json_serializable', () {
      final obj = SimpleObject(42);

      // Compare serialization
      final sb = StringBuffer();
      obj.toWriter(JsonWriter(sb));
      final streamingJson = sb.toString();

      final mapJson = jsonEncode(obj.toJson());
      check(streamingJson).equals(mapJson);

      // Compare deserialization
      const jsonStr = '{"value":42}';

      final reader = JsonReader.fromString(jsonStr);
      final fromReaderObj = SimpleObject.fromReader(reader);

      final fromJsonObj = SimpleObject.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );

      check(fromReaderObj).equals(fromJsonObj);
    });
  });
}
