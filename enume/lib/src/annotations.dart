@deprecated
class Name {
  const Name();
}

@deprecated
const name = Name();

@deprecated
class TypedEnum<T> {
  final T type;

  const TypedEnum(this.type);
}

@deprecated
const intEnum = TypedEnum(int);

@deprecated
const stringEnum = TypedEnum(String);

class Value {
  final dynamic value;
  final String name;

  const Value(this.value, {this.name = 'value'});
}

class Enume {
  final bool nameMethod;

  const Enume({
    this.nameMethod = true,
  });
}
