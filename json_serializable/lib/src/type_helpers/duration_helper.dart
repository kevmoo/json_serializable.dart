// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;
import 'package:source_helper/source_helper.dart';

import '../default_container.dart';
import '../type_helper.dart';
import '../utils.dart';

class DurationHelper extends TypeHelper {
  const DurationHelper();

  @override
  Object? serialize(
    DartType targetType,
    Object expression,
    TypeHelperContext context,
  ) {
    if (!_matchesType(targetType)) {
      return null;
    }

    final expr = expression is Expression
        ? expression
        : refer(toCodeString(expression));

    return targetType.isNullableType
        ? expr.nullSafeProperty('inMicroseconds')
        : expr.property('inMicroseconds');
  }

  @override
  Object? deserialize(
    DartType targetType,
    Object expression,
    TypeHelperContext context,
    bool defaultProvided,
  ) {
    if (!_matchesType(targetType)) {
      return null;
    }

    final expr = expression is Expression
        ? expression
        : refer(toCodeString(expression));

    // Duration(microseconds: ($expression as num).toInt())
    final output = refer('Duration').newInstance([], {
      'microseconds': expr.asA(refer('num')).property('toInt').call([]),
    });

    return DefaultContainer(expression, output);
  }
}

bool _matchesType(DartType type) =>
    const TypeChecker.fromUrl('dart:core#Duration').isExactlyType(type);
