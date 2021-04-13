/// @see https://github.com/brianegan/flutter_redux/issues/40#issuecomment-384287305
class Nullable<T> {
  T _value;

  Nullable(this._value);

  T get value {
    return _value;
  }
}
