import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

public protocol RequestBodyCreator {
  /// Creates a `GraphQLMap` out of the passed-in operation
  ///
  /// - Parameters:
  ///   - operation: The operation to use
  ///   - sendOperationIdentifiers: Whether or not to send operation identifiers. Should default to `false`.
  ///   - sendQueryDocument: Whether or not to send the full query document. Should default to `true`.
  ///   - autoPersistQuery: Whether to use auto-persisted query information. Should default to `false`.
  /// - Returns: The created `GraphQLMap`
  func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                sendOperationIdentifiers: Bool,
                                                sendQueryDocument: Bool,
                                                autoPersistQuery: Bool) -> GraphQLMap
}

// MARK: - Default Implementation

extension RequestBodyCreator {

  public func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                       sendOperationIdentifiers: Bool,
                                                       sendQueryDocument: Bool,
                                                       autoPersistQuery: Bool) -> GraphQLMap {
    
    return self.__requestBody(for: operation.queryDocument,
                            variables: operation.variables,
                            operationName: operation.operationName,
                            sendQueryDocument: sendQueryDocument,
                            sendOperationIdentifiers: sendOperationIdentifiers,
                            operationIdentifier: operation.operationIdentifier,
                            autoPersistQuery: autoPersistQuery)
  }
  
  /// A non-type-safe request creator to facilitate sending requests not using code generation.
  ///
  /// Note: This is only public for use in `ApolloCodegenLib`, we do **not** recommend or support direct use of this in client applications.
  /// - Parameters:
  ///   - operationDocument: The query/mutation/subscription document, as a string
  ///   - variables: [optional] Any variables to send with the operation
  ///   - operationName: The name of the operation being sent
  ///   - sendQueryDocument: If the query document should be sent - defaults to true.
  ///   - sendOperationIdentifiers: If operation identifers should be sent. Defaults to false
  ///   - operationIdentifier: [Optional] The operation identifier to use, defaults to nil
  ///   - autoPersistQuery: Whether the query should be auto-persisted, defaults to false.
  /// - Returns: The body for the given request, ready to be added as the `httpBody`.
  public func __requestBody(for operationDocument: String,
                            variables: GraphQLMap?,
                            operationName: String,
                            sendQueryDocument: Bool = true,
                            sendOperationIdentifiers: Bool = false,
                            operationIdentifier: String? = nil,
                            autoPersistQuery: Bool = false) -> GraphQLMap {
    
    var body: GraphQLMap = [
      "variables": variables,
      "operationName": operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["id"] = operationIdentifier
    }

    if sendQueryDocument {
      body["query"] = operationDocument
    }

    if autoPersistQuery {
      guard let operationIdentifier = operationIdentifier else {
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
