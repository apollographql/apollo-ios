//
//  TestCustomRequestBodyCreator.swift
//  Apollo
//
//  Created by Kim de Vos on 02/10/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Apollo
import ApolloAPI

struct TestCustomRequestBodyCreator: RequestBodyCreator {

  var stubbedRequestBody: GraphQLMap = ["TestCustomRequestBodyCreator": "TestBodyValue"]

  func requestBody<Operation: GraphQLOperation>(
    for operation: Operation,
    sendOperationIdentifiers: Bool,
    sendQueryDocument: Bool, autoPersistQuery: Bool
  ) -> GraphQLMap {
    stubbedRequestBody
  }
}
