String escapeString(String value) {
  StringBuffer? buffer;
  var lastIndex = 0;

  for (var i = 0; i < value.length; i++) {
    final c = value.codeUnitAt(i);
    final escape = switch (c) {
      34 => '\\"',
      92 => '\\\\',
      8 => '\\b',
      12 => '\\f',
      10 => '\\n',
      13 => '\\r',
      9 => '\\t',
      _ when c < 32 => '\\u${c.toRadixString(16).padLeft(4, '0')}',
      _ => null,
    };

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
