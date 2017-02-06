/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Operation: GraphQLOperation> {
  let operation: Operation
  let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }

  public func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> (GraphQLResult<Operation.Data>, RecordSet?)  {
    let data: Operation.Data?
    let dependentKeys: Set<CacheKey>?
    let records: RecordSet?

    if let dataEntry = body["data"] as? JSONObject {
      let reader = GraphQLResultReader(variables: operation.variables) { field, object, info in
        return (object ?? dataEntry)[field.responseName]
      }
      
      let normalizer = GraphQLResultNormalizer(rootKey: rootKey(forOperation: operation))
      normalizer.cacheKeyForObject = cacheKeyForObject
      reader.delegate = normalizer

      data = try Operation.Data(reader: reader)
      
      records = normalizer.records
      dependentKeys = normalizer.dependentKeys
    } else {
      data = nil
      dependentKeys = nil
      records = nil
    }

    let errors: [GraphQLError]?

    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }

    return (GraphQLResult(data: data, errors: errors, dependentKeys: dependentKeys), records)
  }
}
