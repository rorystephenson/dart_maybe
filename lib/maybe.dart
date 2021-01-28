export 'map.dart';

/// Extracts value from [maybe] if not nothing, else returns [defaultValue].
T some<T>(Maybe<T> maybe, T defaultValue) {
  if (isNothing(maybe)) {
    return defaultValue;
  }
  return maybe._value;
}

/// Converts [maybe] from [Maybe<T>] to [Maybe<U>].
///
/// If [maybe] is nothing, `Maybe<U>.nothing()` is returned, else `Maybe.some` from
/// the value obtained from the [converter] with the original value.
Maybe<U> mapSome<T, U>(Maybe<T> maybe, U Function(T v) converter) {
  if (isNothing(maybe)) {
    return Maybe<U>.nothing();
  }
  assert(converter != null, 'a [converter] must be precised');
  return Maybe.some(converter(maybe._value));
}

/// Tests if [maybe] is nothing.
bool isNothing<T>(Maybe<T> maybe) {
  if (maybe == null || maybe._isNothing) {
    return true;
  }
  return false;
}

/// Tests if [maybe] is some.
bool isSome<T>(Maybe<T> maybe) => !isNothing(maybe);

/// Tests the [maybe] status : executes [some] if it contains a value, [whenNothing] if not.
///
/// When adding [defaultValue], [isSome] is called with the value instead of [isNothing].
void when<T>(Maybe<T> maybe,
    {MaybeNothing nothing, MaybeSome<T> some, MaybeDefault<T> defaultValue}) {
  if (isNothing(maybe)) {
    if (defaultValue != null) {
      if (some != null) {
        some(defaultValue());
      }
    } else if (nothing != null) {
      nothing();
    }
  } else if (some != null) {
    some(maybe._value);
  }
}

/// The [Maybe] type encapsulates an optional value. A value of
/// type [Maybe<T>] either contains a value of type [T] (built with
/// [Maybe<T>.just]), or it is empty (built with [Maybe<T>.nothing]).
class Maybe<T> {
  final bool _isNothing;
  final T _value;

  /// An empty value.
  Maybe.nothing()
      : _isNothing = true,
        _value = null;

  /// Some [value].
  ///
  /// If [nullable], considered as [nothing] if [value] is null.
  ///
  /// If [nothingWhen], considered as [nothing] when predicate is verified.
  Maybe.some(this._value,
      {bool nullable = false, bool Function(T value) nothingWhen})
      : _isNothing = (!nullable && _value == null) ||
            (nothingWhen != null && nothingWhen(_value));

  ///  Delegates to the underlying [_value] hashCode.
  @override
  int get hashCode => isNothing(this) ? 0 : _value.hashCode;

  /// Delegates to the underlying [_value] == operator when possible.
  @override
  bool operator ==(o) {
    if (o is Maybe<T>) {
      var oNothing = isNothing(o);
      var thisNothing = isNothing(this);
      return (oNothing && thisNothing) ||
          (!oNothing && !thisNothing && o._value == _value);
    }

    // ignore: avoid_null_checks_in_equality_operators
    if (o == null && isNothing(this)) {
      return true;
    }

    return false;
  }

  ///  Flattens two nested [maybe] into one.
  static Maybe<T> flatten<T>(Maybe<Maybe<T>> maybe) {
    if (maybe == null || maybe._isNothing) {
      return Maybe.nothing();
    }
    return maybe._value;
  }

  /// Returns a new lazy [Iterable] with all elements with a value in [maybeIterable].
  ///
  /// The matching elements have the same order in the returned iterable
  /// as they have in [maybeIterable].
  static Iterable<T> filter<T>(Iterable<Maybe<T>> maybeIterable) {
    return (maybeIterable == null)
        ? Iterable<T>.empty()
        : maybeIterable
            .where((v) => v != null && !v._isNothing)
            .map((v) => v._value);
  }

  /// Applies the function [f] to each element with a value of [maybeIterable] collection
  /// in iteration order.
  static void forEach<T>(
      Iterable<Maybe<T>> maybeIterable, void Function(T element) f) {
    if (maybeIterable == null) {
      maybeIterable
          .where((v) => v != null && !v._isNothing)
          .map((v) => v._value)
          .forEach(f);
    }
  }

  /// Returns the number of elements with a value in [maybeIterable].
  static int count<T>(Iterable<Maybe<T>> maybeList) {
    return (maybeList == null)
        ? 0
        : maybeList.where((v) => v != null && !v._isNothing).length;
  }
}

typedef MaybeNothing = void Function();

typedef MaybeSome<T> = void Function(T value);

typedef MaybeDefault<T> = T Function();
