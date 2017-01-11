public final class GraphQLResponse<Operation: GraphQLOperation, GraphQLErrorType> where GraphQLErrorType: GraphQLMappable {
  let operation: Operation
  let rootObject: JSONObject
  
  public init(operation: Operation, rootObject: JSONObject) {
    self.operation = operation
    self.rootObject = rootObject
  }
  
  public func parseResult() throws -> GraphQLResult<Operation.Data, GraphQLErrorType> {
    let reader = GraphQLResultReader { field, object, info in
      return (object ?? self.rootObject)[field.responseName]
    }
    
    let data: Operation.Data? = try reader.parse(object: rootObject["data"])
    let errors: [GraphQLErrorType]? = try reader.parse(array: rootObject["errors"])
    
    return GraphQLResult(data: data, errors: errors)
  }
}
