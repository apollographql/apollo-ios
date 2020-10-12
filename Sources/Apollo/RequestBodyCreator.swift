import Foundation
#if !COCOAPODS
import ApolloCore
#endif

public protocol RequestBodyCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                sendOperationIdentifiers: Bool,
                                                sendQueryDocument: Bool,
                                                autoPersistQuery: Bool) -> GraphQLMap
}

extension RequestBodyCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
  ///   - sendQueryDocument: Whether or not to send the full query document. Defaults to true.
  ///   - autoPersistQuery: Whether to use auto-persisted query information. Defaults to false.
  /// - Returns: The created `GraphQLMap`
  public func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                       sendOperationIdentifiers: Bool = false,
                                                       sendQueryDocument: Bool = true,
                                                       autoPersistQuery: Bool = false) -> GraphQLMap {
    self.requestBody(for: operation,
                     sendOperationIdentifiers: sendOperationIdentifiers,
                     sendQueryDocument: sendQueryDocument,
                     autoPersistQuery: autoPersistQuery)
  }
}

// Helper struct to create requests independently of HTTP operations.
public struct ApolloRequestBodyCreator: RequestBodyCreator {
  // Internal init methods cannot be used in public methods
  public init() { }

  public func requestBody<Operation>(for operation: Operation,
                              sendOperationIdentifiers: Bool,
                              sendQueryDocument: Bool,
                              autoPersistQuery: Bool) -> GraphQLMap where Operation : GraphQLOperation {
    var body: GraphQLMap = [
      "variables": operation.variables,
      "operationName": operation.operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["id"] = operationIdentifier
    }

    if sendQueryDocument {
      body["query"] = operation.queryDocument
    }

    if autoPersistQuery {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To enable `autoPersistQueries`, Apollo types must be generated with operationIdentifiers")
      }

      body["extensions"] = [
        "persistedQuery" : ["sha256Hash": operationIdentifier, "version": 1]
      ]
    }

    return body
  }
}
