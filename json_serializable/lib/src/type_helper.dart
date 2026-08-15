// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'type_helpers/config_types.dart';

/// Context information provided in calls to [TypeHelper.serialize] and
/// [TypeHelper.deserialize].
abstract class TypeHelperContext {
  /// The annotated class that code is being generated for.
  ClassElement get classElement;

  /// The field that code is being generated for.
  FieldElement get fieldElement;

  /// [expression] may be just the name of the field or it may an expression
  /// representing the serialization of a value.
  Object? serialize(DartType fieldType, Object expression);

  /// [expression] may be just the name of the field or it may an expression
  /// representing the serialization of a value.
  Object? deserialize(DartType fieldType, Object expression);

  /// Adds [memberContent] to the set of generated, top-level members.
  void addMember(String memberContent);
}

/// Extended context information with includes configuration values
/// corresponding to `JsonSerializableGenerator` settings.
abstract class TypeHelperContextWithConfig extends TypeHelperContext {
  ClassConfig get config;
}

abstract class TypeHelper<T extends TypeHelperContext> {
  const TypeHelper();

  /// Returns Dart code that serializes an [expression] representing a Dart
  /// object of type [targetType].
  ///
  /// If [targetType] is not supported, returns `null`.
  Object? serialize(DartType targetType, Object expression, T context);

  /// Returns Dart code that deserializes an [expression] representing a JSON
  /// literal to into [targetType].
  ///
  /// If [targetType] is not supported, returns `null`.
  Object? deserialize(
    DartType targetType,
    Object expression,
    T context,
    bool defaultProvided,
  );
}
