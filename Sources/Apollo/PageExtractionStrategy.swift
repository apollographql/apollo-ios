public protocol PageExtractionStrategy {
  associatedtype Page: Hashable
  associatedtype Input

  func transform(input: Input) -> Page
}
