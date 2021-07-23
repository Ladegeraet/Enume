import 'package:enume/enume.dart';
import 'package:example/foo.dart';

part 'animal.g.dart';

@stringEnum
enum Animal {
  @Value('value')
  dog,
}
