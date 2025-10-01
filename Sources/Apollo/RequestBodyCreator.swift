@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public protocol JSONRequestBodyCreator: Sendable {

  /// Creates a the JSON body for a GraphQL specification compliant request from the given `GraphQLOperation`.
  ///
  /// - Parameters:
  ///   - operation: The `GraphQLOperation` to create the JSON body for.
  ///   - sendQueryDocument: Whether or not to send the full query document. Should default to `true`.
  ///   - autoPersistQuery: Whether to use auto-persisted query information. Should default to `false`.
  /// - Returns: The created `JSONEncodableDictionary`
  func requestBody<Operation: GraphQLOperation>(
    for operation: Operation,
    sendQueryDocument: Bool,
    autoPersistQuery: Bool
  ) -> JSONEncodableDictionary

}

// MARK: - Default Implementation

public struct DefaultRequestBodyCreator: JSONRequestBodyCreator {
  // Internal init methods cannot be used in public methods
  public init() { }

  public func requestBody<Operation: GraphQLOperation>(
    for operation: Operation,
    sendQueryDocument: Bool,
    autoPersistQuery: Bool    
  ) -> JSONEncodableDictionary {
    var body: JSONEncodableDictionary = [
      "operationName": Operation.operationName,
    ]

    if let variables = operation.__variables {
      body["variables"] = variables._jsonEncodableObject
    }

    if sendQueryDocument {
      guard let document = Operation.definition?.queryDocument else {
        preconditionFailure("To send query documents, Apollo types must be generated with `OperationDefinition`s.")
      }
      body["query"] = document
    }

    if autoPersistQuery {
      guard let operationIdentifier = Operation.operationIdentifier else {
        preconditionFailure("To enable `autoPersistQueries`, Apollo types must be generated with operationIdentifiers")
      }

      body["extensions"] = [
        "persistedQuery" : ["sha256Hash": operationIdentifier, "version": 1]
      ]
    }

    if let clientAwarenessMetadata = ApolloClient.context?.clientAwarenessMetadata {
      clientAwarenessMetadata.applyExtension(to: &body)
    }

    return body
  }
}

// MARK: - Deprecations

@available(*, deprecated, renamed: "JSONRequestBodyCreator")
public typealias RequestBodyCreator = JSONRequestBodyCreator

// Helper struct to create requests independently of HTTP operations.
@available(*, deprecated, renamed: "DefaultRequestBodyCreator")
public typealias ApolloRequestBodyCreator = DefaultRequestBodyCreator
