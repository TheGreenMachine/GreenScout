/// A class that wraps around a value.
/// 
/// It serves to transform primitive types (int, double, etc...) into full heap-allocated objects.
/// This allows you to contain a single reference of a value instead of copying it, which allows
/// the creation of apis that take in a value and modify it. 
class Reference<T> {
  Reference(this.value);

  T value;
  
  @override
  String toString() {
    return value.toString();
  }
}