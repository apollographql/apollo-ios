func min<Type: Comparable>(_ a: Type, _ b: Type?) -> Type {
  return min(a, b ?? a)
}
