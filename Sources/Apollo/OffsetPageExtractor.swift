#if !COCOAPODS
import ApolloAPI
#endif

/// Can extract and identify a `Page` for cursor-based endpoints
public struct OffsetPageExtractor<Query: GraphQLQuery>: PageExtractionStrategy {

  public struct Input: Hashable {
    public let data: Query.Data
    public let offset: Int
    public let pageSize: Int

    init(data: Query.Data, offset: Int, pageSize: Int) {
      self.data = data
      self.offset = offset
      self.pageSize = pageSize
    }
  }

  /// A minimal definiton for a `Page`
  public struct Page: Hashable {
    /// Where in the list the server should start when returning items for a particular query
    public let offset: Int

    public let hasNextPage: Bool

    /// Designated Initializer
    /// - Parameters:
    ///   - offset: Where in the list the server should start when returning items for a particular query
    ///   - resultCount: Number of results in this page
    public init(offset: Int, hasNextPage: Bool) {
      self.offset = offset
      self.hasNextPage = hasNextPage
    }
  }

  private let _transform: (Input) -> Page

  /// Designated initializer
  /// - Parameter transform: A user provided function which can extract a `Page` from a `Query.Data`
  public init(transform: @escaping (Input) -> Page) {
    self._transform = transform
  }

  /// Transforms the `Query.Data` into a `Page` by utilizing the user-provided functions or key paths.
  /// - Parameter input: A query response data.
  /// - Returns: A `Page`.
  public func transform(input: Input) -> Page {
    _transform(input)
  }
}
