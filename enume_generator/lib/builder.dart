import 'package:build/build.dart';
import 'package:enume_generator/src/as_string_generator.dart';

import 'package:source_gen/source_gen.dart';

Builder enumeBuilder(BuilderOptions options) => SharedPartBuilder(
      [
        AsStringGenerator(),
      ],
      'enume',
    );
