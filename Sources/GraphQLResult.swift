/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data> {
  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  
  let dependentKeys: Set<CacheKey>?
  
  init(data: Data?, errors: [GraphQLError]?, dependentKeys: Set<CacheKey>?) {
    self.data = data
    self.errors = errors
    self.dependentKeys = dependentKeys
  }
}
