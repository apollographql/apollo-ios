public final class GraphQLResponse<Operation: GraphQLOperation> {
  let operation: Operation
  let rootObject: JSONObject
  
  init(operation: Operation, rootObject: JSONObject) {
    self.operation = operation
    self.rootObject = rootObject
  }
  
  public func parseResult() throws -> GraphQLResult<Operation.Data> {
    let reader = GraphQLResultReader { field, object, info in
      return (object ?? self.rootObject)[field.responseName]
    }
    
    let data: Operation.Data? = try reader.parse(object: rootObject["data"])
    let errors: [GraphQLError]? = try reader.parse(array: rootObject["errors"])
    
    return GraphQLResult(data: data, errors: errors)
  }
}
