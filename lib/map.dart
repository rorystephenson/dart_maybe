import 'dart:core';

import 'package:maybe/maybe.dart';

/// A map with optional values.
///
/// If a [nothing] is added, it removes an old value.
///
/// If a key isn't present in the map, [nothing] is returned as value.
class MaybeMap<K, V> implements Map<K, Maybe<V>> {
  final Map<K, V> _map;
  final bool _nullable;

  /// Creates a [MaybeMap].
  ///
  /// If [nullable] is `true`, `null` values are considered as `some`.
  MaybeMap({bool nullable = true})
      : _map = {},
        _nullable = nullable;

  /// Creates a [MaybeMap] instance that contains all key/value pairs of
  /// [map] as [some].
  ///
  /// If [nullable] is `true`, `null` values are considered as `some`.
  MaybeMap.fromMap(this._map, {bool nullable = true}) : _nullable = nullable;

  @override
  Maybe<V> operator [](Object key) {
    if (!_map.containsKey(key)) {
      return Maybe<V>.nothing();
    }
    return _someValue(_map[key]);
  }

  @override
  void operator []=(K key, Maybe<V> value) {
    whenMaybe<V>(value, nothing: () {
      _map.remove(key);
    }, some: (v) {
      _map[key] = v;
    });
  }

  @override
  void addAll(Map<K, Maybe<V>> other) => addEntries(other.entries);

  @override
  void addEntries(Iterable<MapEntry<K, Maybe<V>>> newEntries) {
    newEntries.forEach((f) {
      whenMaybe<V>(f.value, some: (v) {
        _map[f.key] = v;
      });
    });
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return map((c, v) => MapEntry<RK, RV>(c as RK, v as RV));
  }

  @override
  void clear() => _map.clear();

  @override
  bool containsKey(Object key) => _map.containsKey(key);

  @override
  bool containsValue(Object value) {
    if (value is Maybe<V> && !isNothing(value)) {
      return _map.containsValue(some(value, null));
    }
    if (value == null) {
      _map.containsValue(null);
    }
    return false;
  }

  @override
  Iterable<MapEntry<K, Maybe<V>>> get entries => _map.entries.map(_mapEntry);

  @override
  void forEach(void Function(K key, Maybe<V> value) f) {
    _map.forEach((k, v) {
      f(k, _someValue(v));
    });
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, Maybe<V> value) f) {
    return Map<K2, V2>.fromEntries(entries.map((e) => f(e.key, e.value)));
  }

  @override
  Maybe<V> putIfAbsent(K key, Maybe<V> Function() ifAbsent) {
    if (!containsKey(key)) {
      var result = ifAbsent();
      this[key] = result;
      return result;
    }
    return _someValue(_map[key]);
  }

  @override
  Maybe<V> remove(Object key) {
    if (containsKey(key)) {
      var v = _map.remove(key);
      return Maybe.some(v, nullable: true);
    }
    return Maybe<V>.nothing();
  }

  @override
  void removeWhere(bool Function(K key, Maybe<V> value) predicate) {
    _map.removeWhere((k, v) => predicate(k, _someValue(v)));
  }

  @override
  Maybe<V> update(K key, Maybe<V> Function(Maybe<V> value) update,
      {Maybe<V> Function() ifAbsent}) {
    if (containsKey(key)) {
      var oldValue = this[key];
      var updated = update(oldValue);
      this[key] = updated;
      return updated;
    } else if (ifAbsent != null) {
      var updated = ifAbsent();
      this[key] = updated;
      return updated;
    }

    throw Error();
  }

  @override
  void updateAll(Maybe<V> Function(K key, Maybe<V> value) update) {
    Map<K, V>.from(_map).forEach((k, cv) {
      var updated = update(k, _someValue(cv));
      this[k] = updated;
    });
  }

  @override
  Iterable<Maybe<V>> get values =>
      _map.values.map((v) => Maybe.some(v, nullable: _nullable));

  MapEntry<K, Maybe<V>> _mapEntry(MapEntry<K, V> entry) =>
      MapEntry<K, Maybe<V>>(entry.key, _someValue(entry.value));

  Maybe<V> _someValue(V v) => Maybe.some(v, nullable: true);
}
