/// A class that wraps around a value.
/// 
/// It serves to transform primitive types (int, double, etc...) into full heap-allocated objects.
/// Which allows you to store a single reference of a value and modify it directly rather than
/// copying it around. It affords the creation of apis that take in a value and have the need
/// to modify it.
class Reference<T> {
  Reference(this.value);

  T value;
  
  @override
  String toString() {
    return value.toString();
  }
}