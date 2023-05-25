#if !COCOAPODS
import ApolloAPI
#endif

/// Can extract and identify a `Page` for cursor-based endpoints
public struct RelayPageExtractor<Query: GraphQLQuery>: PageExtractionStrategy {
  /// A minimal definiton for a `Page` as defined within `Relay`
  public struct Page: Hashable {
    /// Whether or not the response has another page of data
    public let hasNextPage: Bool

    /// The `endCursor` by which we can paginate the next set of results.
    public let endCursor: String?

    /// Designated initializer
    /// - Parameters:
    ///   - hasNextPage: Whether or not the response has another page of data
    ///   - endCursor: The `endCursor` by which we can paginate the next set of results.
    public init(hasNextPage: Bool, endCursor: String?) {
      self.hasNextPage = hasNextPage
      self.endCursor = endCursor
    }
  }

  private let _transform: (Query.Data) -> Page

  /// Designated initializer
  /// - Parameter transform: A user provided function which can extract a `Page` from a `Query.Data`
  public init(transform: @escaping (Query.Data) -> Page) {
    self._transform = transform
  }

  /// Convenience initializer
  /// - Parameters:
  ///   - hasNextPagePath: A `KeyPath` over a `Query.Data` which identifies the `hasNextPage` key within the `Query.Data`.
  ///   - endCursorPath: A `KeyPath` over a `Query.Data` which identifies the `endCursor` key within the `Query.Data`.
  public init(hasNextPagePath: KeyPath<Query.Data, Bool>, endCursorPath: KeyPath<Query.Data, String?>) {
    _transform = { data in
      Page(
        hasNextPage: data[keyPath: hasNextPagePath],
        endCursor: data[keyPath: endCursorPath]
      )
    }
  }

  /// Transforms the `Query.Data` into a `Page` by utilizing the user-provided functions or key paths.
  /// - Parameter input: A query response data.
  /// - Returns: A `Page`.
  public func transform(input: Query.Data) -> Page {
    _transform(input)
  }
}
