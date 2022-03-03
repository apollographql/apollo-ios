import Foundation

/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Data: GraphQLSelectionSet> {

  public let body: JSONObject

  private var rootKey: String
  private var variables: GraphQLMap?

  public init<Operation: GraphQLOperation>(operation: Operation, body: JSONObject) where Operation.Data == Data {
    self.body = body
    rootKey = rootCacheKey(for: operation)
    variables = operation.variables
  }
  
  func setupOperation<Operation: GraphQLOperation> (_ operation: Operation) {
    self.rootKey = rootCacheKey(for: operation)
    self.variables = operation.variables
  }

  /// Parses a response into a `GraphQLResult` and a `RecordSet`.
  /// The result can be sent to a completion block for a request.
  /// The `RecordSet` can be merged into a local cache.
  /// - Parameter cacheKeyForObject: See `CacheKeyForObject`
  /// - Returns: A `GraphQLResult` and a `RecordSet`.
  public func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> (GraphQLResult<Data>, RecordSet?) {
    let errors: [GraphQLError]?

    if let errorsEntry = body["errors"] as? [JSONObject] {
      errors = errorsEntry.map(GraphQLError.init)
    } else {
      errors = nil
    }

    let extensions = body["extensions"] as? JSONObject

    if let dataEntry = body["data"] as? JSONObject {
      let executor = GraphQLExecutor { object, info in
        return object[info.responseKeyForField]
      }
      
      executor.cacheKeyForObject = cacheKeyForObject
      
      let mapper = GraphQLSelectionSetMapper<Data>()
      let normalizer = GraphQLResultNormalizer()
      let dependencyTracker = GraphQLDependencyTracker()
      
      let (data, records, dependentKeys) = try executor.execute(selections: Data.selections,
                                                                on: dataEntry,
                                                                withKey: rootKey,
                                                                variables: variables,
                                                                accumulator: zip(mapper, normalizer, dependencyTracker))
      
      return (
        GraphQLResult(data: data,
                      extensions: extensions,
                      errors: errors,
                      source: .server,
                      dependentKeys: dependentKeys),
        records
      )
    } else {
      return (
        GraphQLResult(data: nil,
                      extensions: extensions,
                      errors: errors,
                      source: .server,
                      dependentKeys: nil),
        nil
      )
    }
  }

  public func parseErrorsOnlyFast() -> [GraphQLError]? {
    guard let errorsEntry = self.body["errors"] as? [JSONObject] else {
      return nil
    }

    return errorsEntry.map(GraphQLError.init)
  }

  public func parseResultFast() throws -> GraphQLResult<Data>  {
    let errors = self.parseErrorsOnlyFast()
    let extensions = body["extensions"] as? JSONObject

    if let dataEntry = body["data"] as? JSONObject {
      let data = try decode(selectionSet: Data.self,
                            from: dataEntry,
                            variables: variables)

      return GraphQLResult(data: data,
                           extensions: extensions,
                           errors: errors,
                           source: .server,
                           dependentKeys: nil)
    } else {
      return GraphQLResult(data: nil,
                           extensions: extensions,
                           errors: errors,
                           source: .server,
                           dependentKeys: nil)
    }
  }
}
