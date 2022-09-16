import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public protocol RequestBodyCreator {
  /// Creates a `JSONEncodableDictionary` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
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

extension RequestBodyCreator {
  
  public func requestBody<Operation: GraphQLOperation>(
    for operation: Operation,
    sendQueryDocument: Bool,
    autoPersistQuery: Bool
  ) -> JSONEncodableDictionary {
    var body: JSONEncodableDictionary = [
      "operationName": Operation.operationName,
    ]

    if let variables = operation.variables {
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

    return body
  }
}

// Helper struct to create requests independently of HTTP operations.
public struct ApolloRequestBodyCreator: RequestBodyCreator {
  // Internal init methods cannot be used in public methods
  public init() { }
}
