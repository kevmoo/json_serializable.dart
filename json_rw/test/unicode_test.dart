import 'dart:convert';
import 'package:json_rw/json_rw.dart';
import 'package:test/test.dart';

const _unicodeStrings = [
  'Îñţérñåţîöñåļîžåţîờñ',
  'blåbærgrød',
  'சிவா அணாமாைல',
  'िसवा अणामालै',
  '𐐒', // Deseret capital letter bee (surrogate pair)
  '5',
  'abcdefghijklmnopqrstuvwxyz',
  '\x7F',
  '\u{80}',
  '\u{7FF}',
  '\u{800}',
  '\u{FFFF}',
  '\u{10000}',
  '\u{10FFFF}',
];

const _testCases = [
  ['"\\u0080"', '\u{80}'],
  ['"\\u07FF"', '\u{7FF}'],
  ['"\\u0800"', '\u{800}'],
  ['"\\uFFFF"', '\u{FFFF}'],
  // Surrogate pairs
  ['"\\uD801\\uDC12"', '𐐒'],
  // Standard escapes
  ['"\\""', '"'],
  ['"\\\\"', '\\'],
  ['"\\/"', '/'],
  ['"\\b"', '\b'],
  ['"\\f"', '\f'],
  ['"\\n"', '\n'],
  ['"\\r"', '\r'],
  ['"\\t"', '\t'],
  // Mixed string
  ['"abc\\n123"', 'abc\n123'],
];

void main() {
  test('StringJsonReader read unicode strings', () {
    for (final s in _unicodeStrings) {
      final jsonString = '"$s"';

      // Sanity check against SDK
      expect(json.decode(jsonString), s);

      final reader = JsonReader.fromString(jsonString);
      expect(reader.peek(), JsonToken.string);
      expect(reader.nextString(), s);
    }
  });

  test('Utf8JsonReader read unicode strings', () {
    for (final s in _unicodeStrings) {
      final jsonString = '"$s"';

      // Sanity check against SDK
      expect(json.decode(jsonString), s);

      final bytes = utf8.encode(jsonString);
      final reader = JsonReader.fromUtf8(bytes);
      expect(reader.peek(), JsonToken.string);
      expect(reader.nextString(), s);
    }
  });

  test('StringJsonReader read unicode with escapes', () {
    for (final testCase in _testCases) {
      final jsonString = testCase[0];
      final expected = testCase[1];

      // Sanity check against SDK
      expect(json.decode(jsonString), expected);

      final reader = JsonReader.fromString(jsonString);
      expect(reader.peek(), JsonToken.string);
      expect(reader.nextString(), expected);
    }
  });

  test('Utf8JsonReader read unicode with escapes', () {
    for (final testCase in _testCases) {
      final jsonString = testCase[0];
      final expected = testCase[1];

      // Sanity check against SDK
      expect(json.decode(jsonString), expected);

      final bytes = utf8.encode(jsonString);
      final reader = JsonReader.fromUtf8(bytes);
      expect(reader.peek(), JsonToken.string);
      expect(reader.nextString(), expected);
    }
  });
}
