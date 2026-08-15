// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;

import '../shared_checkers.dart';
import '../type_helper.dart';
import '../utils.dart';

/// Handles the types corresponding to [simpleJsonTypeChecker], namely
/// [String], [bool], [num], [int], [double].
class ValueHelper extends TypeHelper {
  const ValueHelper();

  @override
  Object? serialize(
    DartType targetType,
    Object expression,
    TypeHelperContext context,
  ) {
    if (targetType.isDartCoreObject ||
        targetType is DynamicType ||
        simpleJsonTypeChecker.isAssignableFromType(targetType)) {
      return expression is Expression
          ? expression
          : CodeExpression(Code(toCodeString(expression)));
    }

    return null;
  }

  @override
  Object? deserialize(
    DartType targetType,
    Object expression,
    TypeHelperContext context,
    bool defaultProvided,
  ) => defaultDecodeLogic(
    targetType,
    expression,
    defaultProvided: defaultProvided,
  );
}
