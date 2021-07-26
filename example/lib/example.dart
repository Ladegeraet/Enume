import 'package:example/animal.dart';
import 'package:example/http_status.dart';

void main() {
  // asString
  var animal = Animal.fish;
  print(animal.name);

  var status = HttpStatus.ok;
  print(status.value);

  print(status.code);
}
