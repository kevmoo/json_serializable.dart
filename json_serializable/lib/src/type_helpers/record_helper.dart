import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' hide RecordType;
import 'package:source_helper/source_helper.dart';

import '../type_helper.dart';
import '../utils.dart';

class RecordHelper extends TypeHelper<TypeHelperContextWithConfig> {
  const RecordHelper();

  @override
  Object? deserialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConfig context,
    bool defaultProvided,
  ) {
    if (targetType is! RecordType) return null;

    final positionalItems = <Expression>[];
    final namedItems = <String, Expression>{};

    const paramName = r'$jsonValue';

    var index = 1;
    for (var field in targetType.positionalFields) {
      final indexer = escapeDartString('\$$index');
      final val = context.deserialize(field.type, '$paramName[$indexer]');
      positionalItems.add(
        val is Expression ? val : CodeExpression(Code(toCodeString(val))),
      );
      index++;
    }
    for (var field in targetType.namedFields) {
      final indexer = escapeDartString(field.name);
      final val = context.deserialize(field.type, '$paramName[$indexer]');
      namedItems[field.name] = val is Expression
          ? val
          : CodeExpression(Code(toCodeString(val)));
    }

    if (positionalItems.isEmpty && namedItems.isEmpty) {
      return literalRecord([], {});
    }

    context.addMember(
      _recordConvertImpl(
        nullable: targetType.isNullableType,
        anyMap: context.config.anyMap,
      ),
    );

    final recordLiteral = literalRecord(positionalItems, namedItems);

    final helperName = _recordConvertName(
      nullable: targetType.isNullableType,
      anyMap: context.config.anyMap,
    );

    final closure = Method(
      (m) => m
        ..requiredParameters.add(Parameter((p) => p..name = paramName))
        ..lambda = true
        ..body = recordLiteral.code,
    ).closure;

    return refer(helperName).call([CodeExpression(Code(expression)), closure]);
  }

  @override
  Object? serialize(
    DartType targetType,
    String expression,
    TypeHelperContextWithConfig context,
  ) {
    if (targetType is! RecordType) return null;

    final maybeBang = targetType.isNullableType ? '!' : '';

    final mapEntries = <Expression, Expression>{};

    var index = 1;
    for (var field in targetType.positionalFields) {
      final indexer = literalString('\$$index', raw: true);
      final val = context.serialize(
        field.type,
        '$expression$maybeBang.\$$index',
      );
      mapEntries[indexer] = val is Expression
          ? val
          : CodeExpression(Code(toCodeString(val)));
      index++;
    }
    for (var field in targetType.namedFields) {
      final indexer = literalString(field.name);
      final val = context.serialize(
        field.type,
        '$expression$maybeBang.${field.name}',
      );
      mapEntries[indexer] = val is Expression
          ? val
          : CodeExpression(Code(toCodeString(val)));
    }

    final mapLiteral = literalMap(
      mapEntries,
      refer('String'),
      refer('dynamic'),
    );

    return targetType.isNullableType
        ? refer(
            expression,
          ).equalTo(literalNull).conditional(literalNull, mapLiteral)
        : mapLiteral;
  }
}

String _recordConvertName({required bool nullable, required bool anyMap}) =>
    '_\$recordConvert${anyMap ? 'Any' : ''}${nullable ? 'Nullable' : ''}';

String _recordConvertImpl({required bool nullable, required bool anyMap}) {
  final name = _recordConvertName(nullable: nullable, anyMap: anyMap);

  var expression =
      'convert(value as ${anyMap ? 'Map' : 'Map<String, dynamic>'})';
  if (nullable) {
    expression = ifNullOrElse('value', 'null', expression);
  }

  return '''
\$Rec${nullable ? '?' : ''} $name<\$Rec>(
  Object? value,
  \$Rec Function(Map) convert,
) =>
  $expression;
''';
}
