/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Operation: GraphQLOperation> {
  let operation: Operation
  let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }

  public func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(GraphQLResult<Operation.Data>, RecordSet?)>  {
    let errors: [GraphQLError]?
    
    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }

    if let dataEntry = body["data"] as? JSONObject {
      let executor = GraphQLExecutor { object, info in
        return Promise(fulfilled: (object ?? dataEntry)[info.responseKeyForField])
      }
      
      executor.cacheKeyForObject = cacheKeyForObject
      
      let mapper = GraphQLResultMapper<Operation.Data>()
      let normalizer = GraphQLResultNormalizer()
      let dependencyTracker = GraphQLDependencyTracker()

      return try executor.execute(selectionSet: Operation.selectionSet, rootKey: rootKey(forOperation: operation), variables: operation.variables, accumulator: zip(mapper, normalizer, dependencyTracker)
        ).then(on: DispatchQueue.global()) { (data, records, dependentKeys) in
        return (GraphQLResult(data: data, errors: errors, dependentKeys: dependentKeys), records)
      }
    } else {
      return Promise(fulfilled: (GraphQLResult(data: nil, errors: errors, dependentKeys: nil), nil))
    }
  }
}
