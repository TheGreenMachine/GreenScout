class Reference<T> {
  Reference(this.value);

  T value;

  @override
  String toString() {
    return value.toString();
  }
}