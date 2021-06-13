import 'package:enume/enume.dart';

part 'difficulty.g.dart';

@intEnum
enum Difficulty {
  @Value(5)
  easy,
  @Value(15)
  medium,
  @Value(25)
  hard
}
