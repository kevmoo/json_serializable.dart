// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:source_helper/source_helper.dart';

import 'constants.dart' show closureArg;
import 'shared_checkers.dart';
import 'utils.dart';

/// Represents a lambda that can be used as a tear-off depending on the context
/// in which it is used.
///
/// Allows generated code to support the
/// https://dart-lang.github.io/linter/lints/unnecessary_lambdas.html
/// lint.
class LambdaResult {
  final Expression expression;
  final String lambda;
  final DartType? asContent;

  Expression get _fullExpression =>
      asContent != null ? _cast(expression, asContent!) : expression;

  LambdaResult(Object expression, this.lambda, {this.asContent})
    : expression = expression is Expression
          ? expression
          : CodeExpression(Code(toCodeString(expression)));

  Expression asInvocation() => refer(lambda).call([_fullExpression]);

  @override
  String toString() => toCodeString(asInvocation());

  static Expression process(Object subField) {
    if (subField is LambdaResult &&
        closureArg == toCodeString(subField._fullExpression)) {
      return refer(subField.lambda);
    }
    return Method(
      (m) => m
        ..requiredParameters.add(Parameter((p) => p..name = closureArg))
        ..lambda = true
        ..body = subField is Expression
            ? subField.code
            : (subField is LambdaResult
                  ? subField.asInvocation().code
                  : Code(toCodeString(subField))),
    ).closure;
  }
}

Expression _cast(Expression expression, DartType targetType) {
  if (targetType.isLikeDynamic) {
    return expression;
  }

  final exprStr = toCodeString(expression);
  final nullableSuffix = targetType.isNullableType ? '?' : '';

  if (coreIterableTypeChecker.isAssignableFromType(targetType)) {
    final itemType = coreIterableGenericType(targetType);
    if (itemType.isLikeDynamic) {
      // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
      // for unparenthesized argument cast.
      return CodeExpression(Code('$exprStr as List$nullableSuffix'));
    }
  }

  if (coreMapTypeChecker.isAssignableFromType(targetType)) {
    final args = targetType.typeArgumentsOf(coreMapTypeChecker)!;
    assert(args.length == 2);

    if (args.every((e) => e.isLikeDynamic)) {
      // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
      // for unparenthesized argument cast.
      return CodeExpression(Code('$exprStr as Map$nullableSuffix'));
    }
  }

  final defaultDecodeValue = defaultDecodeLogic(targetType, exprStr);

  if (defaultDecodeValue != null) {
    return defaultDecodeValue is Expression
        ? defaultDecodeValue
        : CodeExpression(Code(toCodeString(defaultDecodeValue)));
  }

  final typeCode = typeToCode(targetType);
  // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
  // for unparenthesized argument cast.
  return CodeExpression(Code('$exprStr as $typeCode'));
}
