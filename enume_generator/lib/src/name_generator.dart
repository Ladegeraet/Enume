import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class NameGenerator {
  String generateNameExtensionCode(Element element) {
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
