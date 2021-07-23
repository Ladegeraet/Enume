import 'dart:async';

import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:enume/enume.dart';
import 'package:enume_generator/src/name_generator.dart';
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
      code.add(NameGenerator().generateNameExtensionCode(element));
    }

    final valueConfig = _extractValues(element);
    if (valueConfig!.isNotEmpty) {}

    return code.join();
  }

  Map<String, dynamic> readConfig(
      ConstantReader annotation, ClassElement enumeElement) {
    final config = <String, dynamic>{};
    print(enumeElement.fields);
    enumeElement.fields.forEach((field) {
      final configField = annotation.read(field.name).literalValue;
      config.putIfAbsent(field.name, () => configField);
    });

    return config;
  }

  Map<String, dynamic>? _extractValues(ClassElement element) {
    final fieldValues = <String, List>{};
    for (var f in element.fields) {
      if (_valueChecker.hasAnnotationOfExact(f)) {
        _valueChecker.annotationsOf(f).forEach((annotation) {
          final methodNameField = annotation.getField('name')!;
          final value = annotation.getField('value')!;
          final methodName = ConstantReader(methodNameField).stringValue;
          final valueReader = ConstantReader(value);

          if (fieldValues[methodName] == null) {
            fieldValues[methodName] = [];
          }

          fieldValues[methodName]!.add(valueReader.literalValue);
        });
      }
    }
    print(fieldValues);
    return fieldValues;
  }

  String _generateValueExtensionCode(
      ClassElement element, String name, List values) {
    final nameExtension = Extension(
      (e) => e
        ..name = '${element.displayName}$name'
        ..on = refer(element.displayName)
        ..methods.add(
          Method(
            (m) => m
              ..name = name
              ..returns = refer(values.first.runtimeType.toString())
              ..lambda = true
              ..type = MethodType.getter
              ..body = _generateBody(element, fieldValues),
          ),
        ),
    );

    final emitter = DartEmitter();
    return DartFormatter().format('${nameExtension.accept(emitter)}');
  }

  String _generateCase(String enumName, String key, dynamic value) {
    return 'case $enumName.$key: return ${value.toString()};';
  }

  Code _generateBody(Element element, List values) {
    // String code =
    final cases = values.fold('', (previousValue, element) => _generateCase(element.displayName, , ));

    return Code('switch (this) {$cases}');
  }
}
