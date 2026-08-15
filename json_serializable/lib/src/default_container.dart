// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_builder/code_builder.dart';

import 'lambda_result.dart';
import 'utils.dart';

/// Represents an expression that may be represented differently if there is
/// a default value available to replace it if `null`.
class DefaultContainer {
  final Expression expression;
  final Object output;

  DefaultContainer(Object expression, this.output)
    : expression = expression is Expression
          ? expression
          : CodeExpression(Code(toCodeString(expression)));

  static Object deserialize(
    Object value, {
    bool nullable = false,
    String? defaultValue,
  }) {
    if (value is DefaultContainer) {
      if (defaultValue != null || nullable) {
        final ifNull = defaultValue != null
            ? CodeExpression(Code(defaultValue))
            : literalNull;
        final outputExpr = value.output is LambdaResult
            ? (value.output as LambdaResult).asInvocation()
            : (value.output is Expression
                  ? value.output as Expression
                  : CodeExpression(Code(toCodeString(value.output))));
        return value.expression
            .equalTo(literalNull)
            .conditional(ifNull, outputExpr);
      }
      value = value.output;
    }

    if (value is LambdaResult && defaultValue != null) {
      return value.expression
          .equalTo(literalNull)
          .conditional(
            CodeExpression(Code(defaultValue)),
            value.asInvocation(),
          );
    }

    if (defaultValue != null) {
      final valExpr = value is Expression
          ? value
          : (value is LambdaResult
                ? value.asInvocation()
                : CodeExpression(Code(toCodeString(value))));
      return valExpr.ifNullThen(CodeExpression(Code(defaultValue)));
    }
    return value;
  }

  @override
  String toString() => toCodeString(deserialize(this));
}
