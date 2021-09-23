//
//  RequestBodyCreatorTests.swift
//  ApolloTests
//
//  Created by Kim de Vos on 16/07/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import Nimble
import ApolloTestSupport
@testable import Apollo
@testable import ApolloAPI

class RequestBodyCreatorTests: XCTestCase {

  func create<Operation: GraphQLOperation>(
    with creator: RequestBodyCreator,
    for operation: Operation
  ) -> JSONEncodableDictionary {
    creator.requestBody(for: operation,                        
                        sendQueryDocument: true,
                        autoPersistQuery: false)
  }
  
  // MARK: - Tests
  
  func testRequestBodyWithApolloRequestBodyCreator() {
    // given
    let operation = MockOperation.mock()
    operation.operationName = "Test Operation Name"
    operation.variables = ["TestVar": 123]
    operation.stubbedQueryDocument = "Test Query Document"

    let creator = ApolloRequestBodyCreator()

    // when
    let actual = self.create(with: creator, for: operation)

    // then
    expect(actual["operationName"]).to(equalJSONValue("Test Operation Name"))
    expect(actual["variables"]).to(equalJSONValue(["TestVar": 123]))
    expect(actual["query"]).to(equalJSONValue("Test Query Document"))
  }

  func testRequestBodyWithCustomRequestBodyCreator() {
    // given
    let creator = TestCustomRequestBodyCreator()
    let expected = creator.stubbedRequestBody

    // when
    let actual = self.create(with: creator, for: MockOperation.mock())

    // then
    expect(actual).to(equalJSONValue(expected))
  }

  #warning("""
TODO: Test generated input objects converted to variables correctly.
- nil variable value
- null variable value
""")
}

