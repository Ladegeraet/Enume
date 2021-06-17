import 'dart:async';

import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
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

    _extractIntValues(element);

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

  Map<String, dynamic>? _extractIntValues(ClassElement element) {
    final fieldValues = <dynamic, dynamic>{};
    print('methodName?');
    for (var f in element.fields) {
      if (_valueChecker.hasAnnotationOfExact(f)) {
        _valueChecker.annotationsOf(f).forEach((annotation) {
          final methodName = annotation.getField('name')!;
          final value = annotation.getField('value')!;
          final methodNameReader = ConstantReader(methodName);
          final valueReader = ConstantReader(value);
          print(f.name);

          if (fieldValues[methodNameReader.stringValue] == null) {
            fieldValues[methodNameReader.stringValue] = <String, List>{};
          }

          if (fieldValues[methodNameReader.stringValue]
                  [value.type.toString()] ==
              null) {
            fieldValues[methodNameReader.stringValue]
                [value.type.toString()] = [];
          }

          fieldValues[methodNameReader.stringValue][value.type.toString()]
              .add(valueReader.literalValue);
        });

        // print(annotation.isLiteral);
        // if (annotation.isList) {
        //   print(annotation.toString());
        // } else if (annotation.isLiteral) {
        //   print(annotation.literalValue);
        // }
      }
    }
    print(fieldValues);
    return null;
  }
}
