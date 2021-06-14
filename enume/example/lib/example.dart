import 'package:example/animal.dart';
import 'package:example/colors.dart';
import 'package:example/difficulty.dart';

void main() {
  // asString
  var animal = Animal.fish;
  print(animal.name);

  // TypedEnums
  print(Colors.blue.value);

  final experience = 45;
  if (experience > Difficulty.hard.value) {
    print('Lorem ipsum dolor sit amet...');
  }
}
