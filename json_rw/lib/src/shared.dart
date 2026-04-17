String escapeString(String value) {
  StringBuffer? buffer;
  var lastIndex = 0;

  for (var i = 0; i < value.length; i++) {
    final c = value.codeUnitAt(i);
    String? escape;

    if (c == 34) {
      escape = '\\"';
    } else if (c == 92) {
      escape = '\\\\';
    } else if (c < 32) {
      switch (c) {
        case 8:
          escape = '\\b';
        case 12:
          escape = '\\f';
        case 10:
          escape = '\\n';
        case 13:
          escape = '\\r';
        case 9:
          escape = '\\t';
        default:
          escape = '\\u${c.toRadixString(16).padLeft(4, '0')}';
      }
    }

    if (escape != null) {
      buffer ??= StringBuffer();
      if (i > lastIndex) {
        buffer.write(value.substring(lastIndex, i));
      }
      buffer.write(escape);
      lastIndex = i + 1;
    }
  }

  if (buffer == null) return value;

  if (lastIndex < value.length) {
    buffer.write(value.substring(lastIndex));
  }
  return buffer.toString();
}
