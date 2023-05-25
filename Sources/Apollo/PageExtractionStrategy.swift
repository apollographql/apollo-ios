/// The strategy by which we extract a `Page` from some given `Input`.
public protocol PageExtractionStrategy {
  associatedtype Page: Hashable
  associatedtype Input

  /// Given some `Input`, we output a `Page`.
  /// - Parameter input: Any value, such as `Query.Data` or a set of `Variables`.
  /// - Returns: `Page`
  func transform(input: Input) -> Page
}
