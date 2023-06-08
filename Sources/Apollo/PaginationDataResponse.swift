#if !COCOAPODS
import ApolloAPI
#endif

/// The response object of a `GraphQLPaginatedQueryWatcher`
public struct PaginationDataResponse<Query: GraphQLQuery, T> {
  /// All responses, in page-order
  public let allResponses: [T]

  /// The response which triggered the watcher to update
  public let mostRecent: T

  /// The source of that most recent trigger
  public let source: GraphQLResult<Query.Data>.Source

  /// Designated initializer
  /// - Parameters:
  ///   - allResponses: All responses, in page-order
  ///   - mostRecent: The response which triggered the watcher to update
  ///   - source: The source of that most recent trigger
  public init(allResponses: [T], mostRecent: T, source: GraphQLResult<Query.Data>.Source) {
    self.allResponses = allResponses
    self.mostRecent = mostRecent
    self.source = source
  }
}

/// The output object to be used in the result handler of a `GraphQLPaginatedQueryWatcher` -- functionally identical to a `GraphQLResult`, but strips away the requirement for the output object to be a `RootSelectionSet` as well as fields that don't make sense in the context of a paginated response, such as `dependentKeys` and `extensions`.
public struct PaginatedOutput<Query: GraphQLQuery, T> {

  /// The transformed output of pagination. Can be a `Query.Data` or a custom object.
  public let value: T

  /// Errors associated with this response.
  public let errors: [GraphQLError]?

  /// The source of the update for this response.
  public let source: GraphQLResult<Query.Data>.Source

  /// Designated initializer
  /// - Parameters:
  ///   - value: The transformed output of pagination. Can be a `Query.Data` or a custom object.
  ///   - errors: Errors associated with this response.
  ///   - source: The source of the update for this response.
  public init(
    value: T,
    errors: [GraphQLError]?,
    source: GraphQLResult<Query.Data>.Source
  ) {
    self.value = value
    self.errors = errors
    self.source = source
  }
}
