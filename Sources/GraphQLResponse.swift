public final class GraphQLResponse<Operation: GraphQLOperation> {
  let operation: Operation
  let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }

  func parseResult(delegate: GraphQLResultReaderDelegate? = nil) throws -> GraphQLResult<Operation.Data>  {
    let data: Operation.Data?

    if let dataEntry = body["data"] as? JSONObject {
      let reader = GraphQLResultReader(variables: operation.variables) { field, object, info in
        return (object ?? dataEntry)[field.responseName]
      }

      reader.delegate = delegate

      data = try Operation.Data(reader: reader)
    } else {
      data = nil
    }

    let errors: [GraphQLError]?

    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }

    return GraphQLResult(data: data, errors: errors)
  }
}
