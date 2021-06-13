import 'dart:async';

import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:enume/enume.dart';
import 'package:enume_generator/src/validator.dart';
import 'package:source_gen/source_gen.dart';

class AsStringGenerator extends GeneratorForAnnotation<AsString> {
  const AsStringGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (!EnumValidator.isEnum(element.enclosingElement)) {
      throw InvalidGenerationSourceError(
          '${element.displayName} is not a enum and cannot be annotated with @asString',
          element: element,
          todo: 'Add asString annotations only to a enum');
    }
    return _generateAsString(element);
  }

  String _generateAsString(Element element) {
    final asStringExtension = Extension(
      (e) => e
        ..name = 'AsString'
        ..on = refer(element.displayName)
        ..methods.add(
          Method(
            (m) => m
              ..name = 'asString'
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
    return DartFormatter().format('${asStringExtension.accept(emitter)}');
  }
}
