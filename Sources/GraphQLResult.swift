public struct GraphQLResult<Data> {
  public let data: Data?
  public let errors: [GraphQLError]?
  
  let dependentKeys: Set<CacheKey>?
  
  init(data: Data?, errors: [GraphQLError]?, dependentKeys: Set<CacheKey>?) {
    self.data = data
    self.errors = errors
    self.dependentKeys = dependentKeys
  }
}
