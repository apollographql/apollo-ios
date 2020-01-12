/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Operation: GraphQLOperation> {
  public let operation: Operation
  public let body: JSONObject

  public init(operation: Operation, body: JSONObject) {
    self.operation = operation
    self.body = body
  }
  
  func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> Promise<(GraphQLResult<Operation.Data>, RecordSet?, GraphQLResultContext)>  {
    let errors: [GraphQLError]?
    
    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }
    
    if let dataEntry = body["data"] as? JSONObject {
      let executor = GraphQLExecutor { object, info in
        return .result(.success((object[info.responseKeyForField], Date().milisecondsSince1970)))
      }
      
      executor.cacheKeyForObject = cacheKeyForObject
      
      let mapper = GraphQLSelectionSetMapper<Operation.Data>()
      let normalizer = GraphQLResultNormalizer()
      let dependencyTracker = GraphQLDependencyTracker()
      let firstModificationTracker = GraphQLFirstModifiedAtTracker()
      
      return firstly {
        try executor.execute(selections: Operation.Data.selections,
                             on: dataEntry,
                             firstModifiedAt: Date().milisecondsSince1970,
                             withKey: rootCacheKey(for: operation),
                             variables: operation.variables,
                             accumulator: zip(mapper, normalizer, dependencyTracker, firstModificationTracker))
        }.map { (data, records, dependentKeys, resultContext) in
          return (
            GraphQLResult(data: data,
                         errors: errors,
                         source: .server,
                         dependentKeys: dependentKeys),
            records,
            resultContext
          )
      }
    } else {
      return Promise(fulfilled: (
        GraphQLResult(data: nil,
                      errors: errors,
                      source: .server,
                      dependentKeys: nil),
        nil,
        GraphQLResultContext()
      ))
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
      let data = try decode(selectionSet: Operation.Data.self,
                            from: dataEntry,
                            variables: operation.variables)
      
      return GraphQLResult(data: data,
                           errors: errors,
                           source: .server,
                           dependentKeys: nil)
    } else {
      return GraphQLResult(data: nil,
                           errors: errors,
                           source: .server,
                           dependentKeys: nil)
    }
  }
}
