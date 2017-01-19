public struct GraphQLResult<Data> {
  public let data: Data?
  public let errors: [GraphQLError]?
  
  init(data: Data?, errors: [GraphQLError]?) {
    self.data = data
    self.errors = errors
  }
}
