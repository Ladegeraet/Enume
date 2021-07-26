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
@Enume()
enum Animal {
  dog,
  cat,
  fish,
  fox,
}

// Example
print(Animal.dog.name); // "dog"
```

### Value
Generates a __value__ getter method that returns the associated annoted value. (Currently only literals are supported!)
```dart
@Enume(nameMethod: false)
enum HttpStatus {
  @Value(200, name: 'code')
  @Value('OK')
  ok,
  @Value(400, name: 'code')
  @Value('Bad Request')
  badRequest,
  @Value(407, name: 'code')
  @Value('Proxy Authentication Required')
  conflict,
}

// Example
print(HttpStatus.ok.value); // 20
print(HttpStatus.conflict.code); // "Proxy Authentication Required"
```

## Roadmap

- Support for all Built-in types and maybe __dynamics__
