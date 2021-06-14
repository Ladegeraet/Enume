class Name {
  const Name();
}

const name = Name();

class TypedEnum<T> {
  final T type;

  const TypedEnum(this.type);
}

const intEnum = TypedEnum(int);
const stringEnum = TypedEnum(String);

class Value {
  final dynamic value;

  const Value(this.value);
}
