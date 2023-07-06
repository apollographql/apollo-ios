#if !COCOAPODS
import ApolloAPI
#endif

/// Can extract and identify a `Page` for cursor-based endpoints
public struct OffsetPageExtractor<Query: GraphQLQuery>: PageExtractionStrategy {

  /// A formed input for the `OffsetPageExtractor`
  public struct Input: Hashable {

    /// The `Query.Data`
    public let data: Query.Data

    /// The current offset
    public let offset: Int

    /// The number of expected results per page
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

    /// Whether or not there is potentially another page of results
    public let hasNextPage: Bool

    /// Designated Initializer
    /// - Parameters:
    ///   - offset: Where in the list the server should start when returning items for a particular query
    ///   - hasNextPage: Whether or not there is potentially another page of results
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

  /// Convenience initializer
  /// - Parameter arrayKeyPath: A `KeyPath` over a `Query.Data` which identifies the array key within the `Query.Data`.
  public init(arrayKeyPath: KeyPath<Query.Data, [(some SelectionSet)?]?>) {
    self._transform = { input in
      let count = input.data[keyPath: arrayKeyPath]?.count ?? 0
      return Page(offset: input.offset + count, hasNextPage: count == input.pageSize)
    }
  }

  /// Convenience initializer
  /// - Parameter arrayKeyPath: A `KeyPath` over a `Query.Data` which identifies the array key within the `Query.Data`.
  public init(arrayKeyPath: KeyPath<Query.Data, [(some SelectionSet)]?>) {
    self._transform = { input in
      let count = input.data[keyPath: arrayKeyPath]?.count ?? 0
      return Page(offset: input.offset + count, hasNextPage: count == input.pageSize)
    }
  }

  /// Transforms the `Query.Data` into a `Page` by utilizing the user-provided functions or key paths.
  /// - Parameter input: A query response data.
  /// - Returns: A `Page`.
  public func transform(input: Input) -> Page {
    _transform(input)
  }
}
