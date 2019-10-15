/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Operation: GraphQLOperation> {
  public let operation: Operation
  public let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }
  
  func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(GraphQLResult<Operation.Data>, RecordSet?)>  {
    let errors: [GraphQLError]?
    
    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }
    
    if let dataEntry = body["data"] as? JSONObject {
      let executor = GraphQLExecutor { object, info in
        return .result(.success(object[info.responseKeyForField]))
      }
      
      executor.cacheKeyForObject = cacheKeyForObject
      
      let mapper = GraphQLSelectionSetMapper<Operation.Data>()
      let normalizer = GraphQLResultNormalizer()
      let dependencyTracker = GraphQLDependencyTracker()
      
      return firstly {
        try executor.execute(selections: Operation.Data.selections, on: dataEntry, withKey: rootCacheKey(for: operation), variables: operation.variables, accumulator: zip(mapper, normalizer, dependencyTracker))
        }.map { (data, records, dependentKeys) in
          (GraphQLResult(data: data, errors: errors, source: .server, dependentKeys: dependentKeys), records)
      }
    } else {
      return Promise(fulfilled: (GraphQLResult(data: nil, errors: errors, source: .server, dependentKeys: nil), nil))
    }
  }
  
  func parseErrorsOnlyFast() -> [GraphQLError]? {
    guard let errorsEntry = self.body["errors"] as? [JSONObject] else {
      return nil
    }
    
    return errorsEntry.map(GraphQLError.init)
  }
  
  func parseResultFast() throws -> GraphQLResult<Operation.Data>  {
    let errors = self.parseErrorsOnlyFast()
    
    if let dataEntry = body["data"] as? JSONObject {      
      let data = try decode(selectionSet: Operation.Data.self, from: dataEntry, variables: operation.variables)
      return GraphQLResult(data: data, errors: errors, source: .server, dependentKeys: nil)
    } else {
      return GraphQLResult(data: nil, errors: errors, source: .server, dependentKeys: nil)
    }
  }
}
