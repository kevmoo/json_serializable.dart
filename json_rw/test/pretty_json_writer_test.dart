import 'dart:convert';
import 'package:json_rw/json_rw.dart';
import 'package:test/test.dart';

void main() {
  test('spaces default (2)', () {
    final sb = StringBuffer();
    JsonWriter(sb, indentType: IndentType.spaces)
      ..beginObject()
      ..name('name')
      ..writeString('value')
      ..name('list')
      ..beginArray()
      ..writeNumber(1)
      ..writeNumber(2)
      ..endArray()
      ..endObject();

    expect(sb.toString(), '''
{
  "name": "value",
  "list": [
    1,
    2
  ]
}''');
  });

  test('tabs default (1)', () {
    final sb = StringBuffer();
    JsonWriter(sb, indentType: IndentType.tabs)
      ..beginObject()
      ..name('name')
      ..writeString('value')
      ..endObject();

    expect(sb.toString(), '''
{
\t"name": "value"
}''');
  });

  test('custom count', () {
    final sb = StringBuffer();
    JsonWriter(sb, indentType: IndentType.spaces, indentCount: 4)
      ..beginObject()
      ..name('name')
      ..writeString('value')
      ..endObject();

    expect(sb.toString(), '''
{
    "name": "value"
}''');
  });

  test('empty objects/arrays', () {
    final sb = StringBuffer();
    JsonWriter(sb, indentType: IndentType.spaces)
      ..beginObject()
      ..name('emptyObj')
      ..beginObject()
      ..endObject()
      ..name('emptyArr')
      ..beginArray()
      ..endArray()
      ..endObject();

    expect(sb.toString(), '''
{
  "emptyObj": {},
  "emptyArr": []
}''');
  });

  test('matches dart:convert withIndent', () {
    final map = <String, dynamic>{
      'name': 'value',
      'list': <int>[1, 2],
      'emptyObj': <String, dynamic>{},
      'emptyArr': <dynamic>[],
    };

    final sb = StringBuffer();
    JsonWriter(sb, indentType: IndentType.spaces)
      ..beginObject()
      ..name('name')
      ..writeString('value')
      ..name('list')
      ..beginArray()
      ..writeNumber(1)
      ..writeNumber(2)
      ..endArray()
      ..name('emptyObj')
      ..beginObject()
      ..endObject()
      ..name('emptyArr')
      ..beginArray()
      ..endArray()
      ..endObject();

    final ourOutput = sb.toString();
    final dartOutput = const JsonEncoder.withIndent('  ').convert(map);

    expect(ourOutput, dartOutput);
  });
}
