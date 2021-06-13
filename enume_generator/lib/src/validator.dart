import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

class EnumValidator {
  static bool isEnum(Element? element) {
    if (element == null) {
      return false;
    }
    final visitor = _EnumVisitor();
    element.visitChildren(visitor);
    return visitor.elementIsEnum;
  }
}

class _EnumVisitor extends SimpleElementVisitor {
  bool elementIsEnum = false;

  @override
  dynamic visitClassElement(ClassElement element) {
    elementIsEnum = element.isEnum;
    return super.visitClassElement(element);
  }
}
