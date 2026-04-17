import 'package:checks/checks.dart';
import 'package:json_rw/src/chunked_lexer.dart';
import 'package:json_rw/src/json_token.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('ChunkedLexer', () {
    test('simple tokens', () {
      final lexer = ChunkedLexer()..addChunk('{"name": "John"}');

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
      final lexer = ChunkedLexer()..addChunk('"Hello ');

      check(lexer.nextToken()).isTrue();
      check(lexer.isPartial).isTrue();
      check(lexer.stringValue).equals('Hello ');

      lexer.addChunk('World"');
      check(lexer.nextToken()).isTrue();
      check(lexer.isPartial).isFalse();
      check(lexer.stringValue).equals('Hello World');
    });

    test('split keyword', () {
      final lexer = ChunkedLexer()..addChunk('tr');

      check(lexer.nextToken()).isFalse(); // Needs more data

      lexer.addChunk('ue');
      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.boolean);
      check(lexer.stringValue).equals('true');
    });

    test('split number', () {
      final lexer = ChunkedLexer()..addChunk('12');

      check(lexer.nextToken()).isFalse(); // Needs more data

      lexer.addChunk('34 '); // Space to terminate number
      check(lexer.nextToken()).isTrue();
      check(lexer.currentToken).equals(JsonToken.number);
      check(lexer.stringValue).equals('1234');
    });

    test('control character in string', () {
      final lexer = ChunkedLexer();
      final ctrlStr = String.fromCharCodes([34, 10, 34]); // "\n"
      lexer.addChunk(ctrlStr);

      check(lexer.nextToken).throws<FormatException>();
    });
  });
}
