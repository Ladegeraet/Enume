import 'dart:async';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:enume/enume.dart';
import 'package:enume_generator/src/validator.dart';
import 'package:source_gen/source_gen.dart';

class TypedEnumGenerator extends GeneratorForAnnotation<TypedEnum> {
  final _valueChecker = const TypeChecker.fromRuntime(Value);
  final _typeChecker = const TypeChecker.fromRuntime(TypedEnum);

  const TypedEnumGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (!EnumValidator.isEnum(element.enclosingElement)) {
      throw InvalidGenerationSourceError(
          '${element.displayName} is not a enum and cannot be annotated with @TypedEnum',
          element: element,
          todo: 'Add TypedEnum annotations only to a enum');
    }

    final enumType = _typeChecker
        .firstAnnotationOfExact(element)
        ?.getField('type')
        ?.toTypeValue();

    if (enumType!.isDartCoreInt) {
      final fieldValues = _extractIntValues(element as ClassElement);
      return _generateTypedEnumExtension(element, fieldValues);
    } else if (enumType.isDartCoreString) {
      final fieldValues = _extractStringValues(element as ClassElement);
      return _generateTypedEnumExtension(element, fieldValues);
    }

    throw InvalidGenerationSourceError(
        'TypedEnums of type [$enumType] are currently not supported',
        element: null,
        todo: 'use intEnum or stringEnum');
  }

  Map<String, int> _extractIntValues(ClassElement element) {
    // ignore: omit_local_variable_types
    Map<String, int> fieldValues = {};

    for (var f in element.fields) {
      if (_valueChecker.hasAnnotationOfExact(f)) {
        final value = _valueChecker
            .firstAnnotationOfExact(f)
            ?.getField('value')
            ?.toIntValue();
        if (value != null) {
          fieldValues[f.displayName] = value;
        }
      }
    }
    return fieldValues;
  }

  Map<String, String> _extractStringValues(ClassElement element) {
    // ignore: omit_local_variable_types
    Map<String, String> fieldValues = {};

    for (var f in element.fields) {
      if (_valueChecker.hasAnnotationOfExact(f)) {
        final value = _valueChecker
            .firstAnnotationOfExact(f)
            ?.getField('value')
            ?.toStringValue();
        if (value != null) {
          fieldValues[f.displayName] = '\'$value\'';
        }
      }
    }
    return fieldValues;
  }

  String _generateCase(String enumName, String key, dynamic value) {
    return 'case $enumName.$key: return ${value.toString()};';
  }

  Code _generateBody(Element element, Map<String, dynamic> fieldValues) {
    // String code =
    final cases = fieldValues
        .map(
          (key, value) => MapEntry(
            key,
            _generateCase(element.displayName, key, value),
          ),
        )
        .values
        .fold<String>(
          '',
          (previousValue, element) => previousValue + element,
        );

    return Code('switch (this) {$cases}');
  }

  String _generateTypedEnumExtension(
      Element element, Map<String, dynamic> fieldValues) {
    final extension = Extension(
      (e) => e
        ..name = 'Values'
        ..on = refer(element.displayName)
        ..methods.add(
          Method(
            (m) => m
              ..name = 'value'
              ..returns = refer(fieldValues.values.first.runtimeType.toString())
              ..lambda = false
              ..type = MethodType.getter
              ..body = _generateBody(element, fieldValues),
          ),
        ),
    );

    final emitter = DartEmitter();
    return DartFormatter().format('${extension.accept(emitter)}');
  }
}

class TypedEnumFieldsVisitor extends SimpleElementVisitor {
  Map<String, DartType> fields = {};
  Map<String, dynamic> metaData = {};

  @override
  dynamic visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;
    metaData[element.name] = element.metadata;
    super.visitFieldElement(element);
  }
}
