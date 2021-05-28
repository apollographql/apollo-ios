import Foundation

class UntypedGraphQLRequestBodyCreator {
  
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
  static func requestBody(for operationDocument: String,
                          variables: [String: Any]?,
                          operationName: String,
                          sendQueryDocument: Bool = true,
                          sendOperationIdentifiers: Bool = false,
                          operationIdentifier: String? = nil,
                          autoPersistQuery: Bool = false) -> [String: Any?] {
    
    var body: [String: Any?] = [
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
