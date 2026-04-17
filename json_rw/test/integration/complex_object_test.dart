import 'dart:convert';
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

    test('compare behavior with json_serializable', () {
      final obj = ComplexObject(
        name: 'John',
        age: 30,
        objects: [SimpleObject(1), SimpleObject(2)],
        map: {'key1': 'value1', 'key2': 'value2'},
      );

      // Compare serialization
      final sb = StringBuffer();
      obj.toWriter(JsonWriter(sb));
      final streamingJson = sb.toString();

      final mapJson = jsonEncode(obj.toJson());
      check(streamingJson).equals(mapJson);

      // Compare deserialization
      final jsonStr = jsonEncode(obj.toJson());

      final reader = JsonReader.fromString(jsonStr);
      final fromReaderObj = ComplexObject.fromReader(reader);

      final fromJsonObj = ComplexObject.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );

      check(fromReaderObj).equals(fromJsonObj);
    });
  });
}
