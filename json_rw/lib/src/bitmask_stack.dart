import 'package:meta/meta.dart';

/// A class that provides a zero-allocation bitmask stack for tracking JSON
/// scopes.
///
/// This is used as a private delegate by readers to avoid leaking stack methods
/// into the public API.
@internal
final class BitmaskStack {
  int _stack = 0;
  int _depth = 0;

  /// Pushes an object scope onto the stack.
  @pragma('vm:prefer-inline')
  void pushObject() {
    if (_depth >= 60) throw const FormatException('JSON too deep');
    _stack = (_stack << 1) | 1;
    _depth++;
  }

  /// Pushes an array scope onto the stack.
  @pragma('vm:prefer-inline')
  void pushArray() {
    if (_depth >= 60) throw const FormatException('JSON too deep');
    _stack = _stack << 1;
    _depth++;
  }

  /// Pops an object scope from the stack.
  @pragma('vm:prefer-inline')
  void popObject() {
    if (_depth == 0 || (_stack & 1) == 0) {
      throw const FormatException('Not in an object');
    }
    _stack >>= 1;
    _depth--;
  }

  /// Pops an array scope from the stack.
  @pragma('vm:prefer-inline')
  void popArray() {
    if (_depth == 0 || (_stack & 1) == 1) {
      throw const FormatException('Not in an array');
    }
    _stack >>= 1;
    _depth--;
  }

  /// Returns true if the current scope is an object.
  @pragma('vm:prefer-inline')
  bool get isObjectScope => _depth > 0 && (_stack & 1) == 1;

  /// Returns true if the current scope is an array.
  @pragma('vm:prefer-inline')
  bool get isArrayScope => _depth > 0 && (_stack & 1) == 0;

  /// Returns true if the stack is empty.
  @pragma('vm:prefer-inline')
  bool get isStackEmpty => _depth == 0;

  /// Returns the current depth of the stack.
  @pragma('vm:prefer-inline')
  int get stackDepth => _depth;
}
