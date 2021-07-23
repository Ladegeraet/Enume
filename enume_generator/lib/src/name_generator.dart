import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'package:build/build.dart';
import 'package:enume/enume.dart';
import 'package:enume_generator/src/validator.dart';
import 'package:source_gen/source_gen.dart';

class NameGenerator extends GeneratorForAnnotation<Name> {
  const NameGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (!EnumValidator.isEnum(element.enclosingElement)) {
      throw InvalidGenerationSourceError(
          '${element.displayName} is not a enum and cannot be annotated with @name',
          element: element,
          todo: 'Add name annotations only to a enum');
    }
    return _generateName(element);
  }

  String _generateName(Element element) {
    final nameExtension = Extension(
      (e) => e
        ..name = 'Name'
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
