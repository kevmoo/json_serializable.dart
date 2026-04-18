import 'dart:convert';
import 'package:checks/checks.dart';
import 'package:json_rw/src/byte_chunked_lexer.dart';
import 'package:json_rw/src/json_token.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('ByteChunkedLexer', () {
    test('simple tokens', () {
      final lexer = ByteChunkedLexer(
        initialChunk: utf8.encode('{"name": "John"}'),
      );

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.beginObject);

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals('name');

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.colon);

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals('John');

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.endObject);
    });

    test('split string', () {
      final lexer = ByteChunkedLexer(initialChunk: utf8.encode('"Hello '));

      check(lexer.nextToken()).isTrue();
      check(lexer.isPartial).isTrue();
      check(lexer.stringValue).equals('Hello ');

      lexer.addChunk(utf8.encode('World"'));
      check(lexer.nextToken()).isTrue();
      check(lexer.isPartial).isFalse();
      check(lexer.stringValue).equals('Hello World');
    });

    test('split keyword', () {
      final lexer = ByteChunkedLexer(initialChunk: utf8.encode('tr'));

      check(lexer.nextToken()).isFalse(); // Needs more data

      lexer.addChunk(utf8.encode('ue'));
      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.boolean);
      check(lexer.stringValue).equals('true');
    });

    test('split number', () {
      final lexer = ByteChunkedLexer(initialChunk: utf8.encode('12'));

      check(lexer.nextToken()).isFalse(); // Needs more data

      lexer.addChunk(utf8.encode('34 ')); // Space to terminate number
      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.number);
      check(lexer.stringValue).equals('1234');
    });

    test('control character in string', () {
      final lexer = ByteChunkedLexer();
      final ctrlStr = String.fromCharCodes([34, 10, 34]); // "\n"
      lexer.addChunk(utf8.encode(ctrlStr));

      check(lexer.nextToken).throws<FormatException>();
    });

    test('unicode escape', () {
      final lexer = ByteChunkedLexer(
        initialChunk: utf8.encode('"\\u0020"'),
      ); // Space

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals(' ');
    });

    test('other escapes', () {
      final lexer = ByteChunkedLexer(
        initialChunk: utf8.encode('"\\n\\t\\\\\\/\\b\\f\\r"'),
      );

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals('\n\t\\/\b\f\r');
    });

    test('escaped quote', () {
      final lexer = ByteChunkedLexer(initialChunk: utf8.encode('"\\""'));

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals('"');
    });

    test('non-Uint8List chunk', () {
      final lexer = ByteChunkedLexer(
        initialChunk: [34, 97, 98, 99, 34],
      ); // "abc"

      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.string);
      check(lexer.stringValue).equals('abc');
    });
  });
}
