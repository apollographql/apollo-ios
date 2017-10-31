/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data> {
    /// Represents source of data
    public enum Source {
        case cache
        case server
    }

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// Source of data
  public let source:Source
    
  let dependentKeys: Set<CacheKey>?
  
  init(data: Data?, errors: [GraphQLError]?, source:Source, dependentKeys: Set<CacheKey>?) {
    self.data = data
    self.errors = errors
    self.dependentKeys = dependentKeys     
    self.source = source
  }
}
