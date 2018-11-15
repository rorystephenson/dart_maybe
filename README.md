# maybe

[![Pub](https://img.shields.io/pub/v/maybe.svg)](https://pub.dartlang.org/packages/maybe)

No more null check with an dart equivalent of Maybe (Haskel, Elm) / Option (F#).

## Usage

The key is that you need to call the `Maybe.when<T>` method to access your potential value so you are forced to check its status before using it.

```dart
// Defining a value
var maybe = Maybe<String>.some("hello world");
Maybe.when<String>(maybe, some: (v) {
    print(v); // "hello world"
});

// Defining nothing
maybe = Maybe<String>.nothing();
Maybe.when<String>(maybe, some: (v) {
    print(v); // not called!
});

// By default, null as value is considered as nothing
maybe = Maybe<String>.some(null);
Maybe.when<String>(maybe, some: (v) {
    print(v); // not called!
});

// ... but you can explictly activate null values
maybe = Maybe<String>.some(null, nullable: true);
Maybe.when<String>(maybe, some: (v) {
    print(v); // called with null
});

// You can add a default value when nothing
maybe = Maybe<String>.some(null);
Maybe.when<String>(maybe, some: (v) {
        print(v); // "hello world"
    }, 
    defaultValue: () => "hello world");
```