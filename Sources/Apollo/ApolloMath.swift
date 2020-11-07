enum ApolloMath {

  static func min<T: Comparable>(_ a: T, _ b: T?) -> T {
    return min(a, b ?? a)
  }
}
