const _escapes = {
  '"': '\\"',
  '\\': '\\\\',
  '\b': '\\b',
  '\f': '\\f',
  '\n': '\\n',
  '\r': '\\r',
  '\t': '\\t',
};

String escapeString(String value) =>
    value.replaceAllMapped(RegExp(r'["\\\x00-\x1f]'), (match) {
      final c = match.group(0)!;
      final escape = _escapes[c];
      if (escape != null) return escape;
      final code = c.codeUnitAt(0);
      return '\\u${code.toRadixString(16).padLeft(4, '0')}';
    });
