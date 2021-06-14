# Enume - useful enum extensions for dart
Code generation for a Name-Method and TypedEnums, which allows to assign specific values each of the enumerated types.

## Setup

```yaml
dependencies:  
  # add enume to your dependencies  
  enume:  
  
dev_dependencies:  
  # add the enume_generator to your dev_dependencies  
  enume_generator:  
```

## Usage
### Name
Generates a __name__ getter method that returns the name of this enum constant, exactly as declared in its enum declaration.

```dart
@name
enum Animal {
  dog,
  cat,
  fish,
  fox,
}

// Example
print(Animal.dog.name); // "dog"
```

### stringEnum
Generates a __value__ getter method that returns the associated annoted __string__ value.
```dart
@stringEnum
enum Colors {
  @Value('#FF0000')
  red,
  @Value('#00FF00')
  green,
  @Value('#0000FF')
  blue,
}

// Example
print(Colors.red.value); // "#FF0000"
```

### intEnum
Generates a __value__ getter method that returns the associated annoted __int__ value.

```dart
@intEnum
enum Difficulty {
  @Value(5)
  easy,
  @Value(15)
  medium,
  @Value(25)
  hard
}

// Example
print(Difficulty.medium.value); // 15
```

## Roadmap

- Support for all Built-in types and maybe __dynamics__
