public typealias Cursor = String
/// A single set of results from a paginated query
public struct Page: Equatable {
  /// Whether or not there are more results after this set of results
  public let hasNextPage: Bool

  /// The pagination cursor of this set of results. Note that this doesn't explicitly have to be a cursor, but rather any type of `String` identifier for this data set.
  public let endCursor: Cursor?

  public init(hasNextPage: Bool, endCursor: Cursor?) {
    self.hasNextPage = hasNextPage
    self.endCursor = endCursor
  }
}
