import 'package:json_rw/json_rw.dart';
import 'simple_object.dart';

part 'complex_object.g.dart';

class ComplexObject {
  final String name;
  final int age;
  final List<SimpleObject> objects;
  final Map<String, String> map;

  ComplexObject({
    required this.name,
    required this.age,
    required this.objects,
    required this.map,
  });

  factory ComplexObject.fromReader(JsonReader reader) =>
      _$ComplexObjectFromReader(reader);

  void toWriter(JsonWriter writer) => _$ComplexObjectToWriter(this, writer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexObject &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          _listEquals(objects, other.objects) &&
          _mapEquals(map, other.map);

  @override
  int get hashCode => Object.hash(name, age, objects, map);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
