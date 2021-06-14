import 'package:build/build.dart';
import 'package:enume_generator/src/name_generator.dart';
import 'package:enume_generator/src/typed_enum_generator.dart';

import 'package:source_gen/source_gen.dart';

Builder enumeBuilder(BuilderOptions options) => SharedPartBuilder(
      [
        NameGenerator(),
        TypedEnumGenerator(),
      ],
      'enume',
    );
