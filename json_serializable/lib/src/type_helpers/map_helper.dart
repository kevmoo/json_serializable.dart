// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:source_helper/source_helper.dart';

import '../constants.dart';
import '../shared_checkers.dart';
import '../type_helper.dart';
import '../unsupported_type_error.dart';
import '../utils.dart';
import 'to_from_string.dart';

const _keyParam = 'k';

class MapHelper extends TypeHelper<TypeHelperContextWithConfig> {
  const MapHelper();

  @override
  Object? serialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConfig context,
  ) {
    if (!coreMapTypeChecker.isAssignableFromType(targetType)) {
      return null;
    }
    final args = targetType.typeArgumentsOf(coreMapTypeChecker)!;
    assert(args.length == 2);

    final keyType = args[0];
    final valueType = args[1];

    _checkSafeKeyType(expression, keyType);

    final subFieldValue = context.serialize(valueType, closureArg);
    final subFieldValueStr = toCodeString(subFieldValue);
    final subKeyValue =
        _forType(keyType)?.serialize(keyType, _keyParam, false) ??
        context.serialize(keyType, _keyParam);
    final subKeyValueStr = toCodeString(subKeyValue);

    if (closureArg == subFieldValueStr && _keyParam == subKeyValueStr) {
      return CodeExpression(Code(expression));
    }

    final target = refer(expression);
    final mapProperty = targetType.isNullableType
        ? target.nullSafeProperty('map')
        : target.property('map');

    final keyExpr = subKeyValue is Expression
        ? subKeyValue
        : CodeExpression(Code(subKeyValueStr));
    final valExpr = subFieldValue is Expression
        ? subFieldValue
        : CodeExpression(Code(subFieldValueStr));

    final mapEntry = refer('MapEntry').newInstance([keyExpr, valExpr]);

    final closure = Method(
      (m) => m
        ..requiredParameters.addAll([
          Parameter((p) => p..name = _keyParam),
          Parameter((p) => p..name = closureArg),
        ])
        ..lambda = true
        ..body = mapEntry.code,
    ).closure;

    return mapProperty.call([closure]);
  }

  @override
  Object? deserialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConfig context,
    bool defaultProvided,
  ) {
    if (!coreMapTypeChecker.isExactlyType(targetType)) {
      return null;
    }

    final typeArgs = targetType.typeArgumentsOf(coreMapTypeChecker)!;
    assert(typeArgs.length == 2);
    final keyArg = typeArgs.first;
    final valueArg = typeArgs.last;

    _checkSafeKeyType(expression, keyArg);

    final valueArgIsAny =
        valueArg is DynamicType ||
        (valueArg.isDartCoreObject && valueArg.isNullableType);
    final isKeyStringable = _isKeyStringable(keyArg);

    final targetTypeIsNullable = defaultProvided || targetType.isNullableType;
    final optionalQuestion = targetTypeIsNullable ? '?' : '';

    if (!isKeyStringable) {
      if (valueArgIsAny) {
        if (context.config.anyMap) {
          if (keyArg.isLikeDynamic) {
            // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
            // for unparenthesized argument cast.
            return CodeExpression(Code('$expression as Map$optionalQuestion'));
          }
        } else {
          // this is the trivial case. Do a runtime cast to the known type of
          // JSON map values - `Map<String, dynamic>`
          // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
          // for unparenthesized argument cast.
          return CodeExpression(
            Code('$expression as Map<String, dynamic>$optionalQuestion'),
          );
        }
      }

      if (!targetTypeIsNullable &&
          (valueArgIsAny ||
              // explicitly exclude double since we need to do an explicit
              // `toDouble` on input values
              valueArg.isSimpleJsonTypeNotDouble)) {
        // No mapping of the values or null check required!
        final valueString = valueArg.getDisplayString();
        // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
        // for unparenthesized argument cast.
        return refer(
          'Map<String, $valueString>',
        ).property('from').call([CodeExpression(Code('$expression as Map'))]);
      }
    }

    // In this case, we're going to create a new Map with matching reified
    // types.

    final itemSubVal = context.deserialize(valueArg, closureArg);

    Object keyUsage;
    if (keyArg.isEnum) {
      keyUsage = context.deserialize(keyArg, _keyParam)!;
    } else if (context.config.anyMap &&
        !(keyArg.isDartCoreObject || keyArg is DynamicType)) {
      // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
      // for unparenthesized argument cast.
      keyUsage = const CodeExpression(Code('$_keyParam as String'));
    } else if (context.config.anyMap &&
        keyArg.isDartCoreObject &&
        !keyArg.isNullableType) {
      // TODO: https://github.com/dart-lang/tools/issues/1140 - using CodeExpression
      // for unparenthesized argument cast.
      keyUsage = const CodeExpression(Code('$_keyParam as Object'));
    } else {
      keyUsage = refer(_keyParam);
    }

    final toFromString = _forType(keyArg);
    if (toFromString != null) {
      keyUsage = toFromString.deserialize(
        keyArg,
        toCodeString(keyUsage),
        false,
        true,
      )!;
    }

    final mapTypeStr = context.config.anyMap ? 'Map' : 'Map<String, dynamic>';
    final castType = refer('$mapTypeStr${targetTypeIsNullable ? '?' : ''}');
    final target = refer(expression).asA(castType);
    final mapProperty = targetTypeIsNullable
        ? target.nullSafeProperty('map')
        : target.property('map');

    final keyExpr = keyUsage is Expression
        ? keyUsage
        : CodeExpression(Code(toCodeString(keyUsage)));
    final valExpr = itemSubVal is Expression
        ? itemSubVal
        : CodeExpression(Code(toCodeString(itemSubVal)));

    final mapEntry = refer('MapEntry').newInstance([keyExpr, valExpr]);

    final closure = Method(
      (m) => m
        ..requiredParameters.addAll([
          Parameter((p) => p..name = _keyParam),
          Parameter((p) => p..name = closureArg),
        ])
        ..lambda = true
        ..body = mapEntry.code,
    ).closure;

    return mapProperty.call([closure]);
  }
}

final _intString = ToFromStringHelper('int.parse', 'toString()', 'int');

/// [ToFromStringHelper] instances representing non-String types that can
/// be used as [Map] keys.
final _instances = [bigIntString, dateTimeString, _intString, uriString];

ToFromStringHelper? _forType(DartType type) =>
    _instances.where((i) => i.matches(type)).singleOrNull;

/// Returns `true` if [keyType] can be automatically converted to/from String –
/// and is therefor usable as a key in a [Map].
bool _isKeyStringable(DartType keyType) =>
    keyType.isEnum || _instances.any((inst) => inst.matches(keyType));

void _checkSafeKeyType(String expression, DartType keyArg) {
  // We're not going to handle converting key types at the moment
  // So the only safe types for key are dynamic/Object/String/enum
  if (keyArg is DynamicType ||
      (!keyArg.isNullableType &&
          (keyArg.isDartCoreObject ||
              coreStringTypeChecker.isExactlyType(keyArg) ||
              _isKeyStringable(keyArg)))) {
    return;
  }

  throw UnsupportedTypeError(
    keyArg,
    expression,
    'Map keys must be one of: ${allowedMapKeyTypes.join(', ')}.',
  );
}

/// The names of types that can be used as [Map] keys.
///
/// Used in [_checkSafeKeyType] to provide a helpful error with unsupported
/// types.
List<String> get allowedMapKeyTypes => [
  'Object',
  'dynamic',
  'enum',
  'String',
  ..._instances.map((i) => i.coreTypeName),
];

extension on DartType {
  bool get isSimpleJsonTypeNotDouble =>
      !isDartCoreDouble && simpleJsonTypeChecker.isAssignableFromType(this);
}
