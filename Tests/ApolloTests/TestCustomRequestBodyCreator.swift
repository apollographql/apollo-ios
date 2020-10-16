//
//  TestCustomRequestBodyCreator.swift
//  Apollo
//
//  Created by Kim de Vos on 02/10/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Apollo

struct TestCustomRequestBodyCreator: RequestBodyCreator {
  func requestBody<Operation: GraphQLOperation>(
    for operation: Operation,
    sendOperationIdentifiers: Bool,
    sendQueryDocument: Bool, autoPersistQuery: Bool) -> GraphQLMap {
    
    var body: GraphQLMap = [
      "test_variables": operation.variables,
      "test_operationName": operation.operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["test_id"] = operationIdentifier
    } else {
      body["test_query"] = operation.queryDocument
    }

    return body
  }
}
