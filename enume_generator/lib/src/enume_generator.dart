import 'dart:async';

import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:enume/enume.dart';
import 'package:enume_generator/src/validator.dart';

import 'package:source_gen/source_gen.dart';

class EnumeGenerator extends GeneratorForAnnotation<Enume> {
  final _valueChecker = const TypeChecker.fromRuntime(Value);

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement ||
        !EnumValidator.isEnum(element.enclosingElement)) {
      throw InvalidGenerationSourceError(
          '${element.displayName} is not a enum and cannot be annotated with @Enume',
          element: element,
          todo: 'Add Enume annotations only to a enum');
    }

    final code = <String>[];

    var enumeElement =
        element.metadata[0].element!.enclosingElement as ClassElement;
    final enumeConfig = readConfig(annotation, enumeElement);

    if (enumeConfig['nameMethod']) {
      code.add(_generateNameExtensionCode(element));
    }

    final values = _extractValues(element);
    var valueMap = <String, List<_GeneratorValue>>{};
    for (var value in values) {
      if (!valueMap.containsKey(value.methodName)) {
        valueMap[value.methodName] = [];
      }
      valueMap[value.methodName]?.add(value);
    }

    for (var entry in valueMap.entries) {
      code.add(_generateValueExtensionCode(element, entry.key, entry.value));
    }

    return code.join();
  }

  Map<String, dynamic> readConfig(
      ConstantReader annotation, ClassElement enumeElement) {
    final config = <String, dynamic>{};
    enumeElement.fields.forEach((field) {
      final configField = annotation.read(field.name).literalValue;
      config.putIfAbsent(field.name, () => configField);
    });
    return config;
  }

  List<_GeneratorValue> _extractValues(ClassElement element) {
    final values = <_GeneratorValue>[];

    for (final field in element.fields) {
      if (_valueChecker.hasAnnotationOfExact(field)) {
        _valueChecker.annotationsOf(field).forEach((annotation) {
          final methodNameField = annotation.getField('name')!;
          final value = annotation.getField('value')!;
          final methodName = ConstantReader(methodNameField).stringValue;
          final valueReader = ConstantReader(value);

          final generatorValue = _GeneratorValue(
              field: field,
              methodName: methodName,
              value: valueReader.literalValue!);
          values.add(generatorValue);
        });
      }
    }

    return values;
  }

  String _generateValueExtensionCode(
      ClassElement classElement, String name, List<_GeneratorValue> values) {
    final nameExtension = Extension(
      (e) => e
        ..name = '${classElement.displayName}$name'
        ..on = refer(classElement.displayName)
        ..methods.add(
          Method(
            (m) => m
              ..name = name
              ..returns = refer(values.first.value.runtimeType.toString())
              ..type = MethodType.getter
              ..body = _generateBody(classElement, values),
          ),
        ),
    );

    final emitter = DartEmitter();
    return DartFormatter().format('${nameExtension.accept(emitter)}');
  }

  String _generateCase(String enumName, String key, Object value) {
    if (value is String) {
      return 'case $enumName.$key: return \'$value\';';
    } else {
      return 'case $enumName.$key: return $value;';
    }
  }

  Code _generateBody(Element classElement, List<_GeneratorValue> values) {
    // String code =

    final cases = values.fold<String>(
      '',
      (previousValue, element) =>
          previousValue +
          _generateCase(
            classElement.displayName,
            element.field.displayName,
            element.value,
          ),
    );

    return Code('switch (this) {$cases}');
  }

  String _generateNameExtensionCode(Element element) {
    final nameExtension = Extension(
      (e) => e
        ..name = '${element.displayName}Name'
        ..on = refer(element.displayName)
        ..methods.add(
          Method(
            (m) => m
              ..name = 'name'
              ..returns = refer('String')
              ..lambda = true
              ..type = MethodType.getter
              ..body = Code(
                'toString().substring(${element.displayName.length + 1})',
              ),
          ),
        ),
    );

    final emitter = DartEmitter();
    return DartFormatter().format('${nameExtension.accept(emitter)}');
  }
}

class _GeneratorValue {
  final FieldElement field;
  final String methodName;
  final Object value;

  _GeneratorValue({
    required this.field,
    required this.methodName,
    required this.value,
  });

  @override
  String toString() {
    return '[field: $field, methodName: $methodName, value: $value]';
  }
}
