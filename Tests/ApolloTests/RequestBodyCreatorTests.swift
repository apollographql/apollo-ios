//
//  RequestBodyCreatorTests.swift
//  ApolloTests
//
//  Created by Kim de Vos on 16/07/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
import Nimble
import ApolloInternalTestHelpers
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
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "Test Operation Name" }
      override class var document: DocumentType { .notPersisted(definition: .init("Test Query Document")) }
    }

    let operation = GivenMockOperation()
    operation.variables = ["TestVar": 123]

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
    let actual = self.create(with: creator, for: MockQuery.mock())

    // then
    expect(actual).to(equalJSONValue(expected))
  }

  func test_requestBody_withCustomScalarVariable_createsBodyWithEncodedJSONValueForVariable() {
    // given
    struct MockScalar: CustomScalarType, Hashable {
      let data: String
      init(_ data: String) {
        self.data = data
      }

      init(jsonValue value: JSONValue) throws {
        data = value as! String
      }

      var _jsonValue: JSONValue { data }
    }

    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "Test Operation Name" }
      override class var document: DocumentType { .notPersisted(definition: .init("Test Query Document")) }
    }

    let operation = GivenMockOperation()
    operation.variables = ["TestVar": MockScalar("123")]

    let creator = ApolloRequestBodyCreator()

    // when
    let actual = self.create(with: creator, for: operation)

    // then
    expect(actual["operationName"]).to(equalJSONValue("Test Operation Name"))
    expect(actual["variables"]).to(equalJSONValue(["TestVar": "123"]))
    expect(actual["query"]).to(equalJSONValue("Test Query Document"))
  }

  #warning("""
TODO: Test generated input objects converted to variables correctly.
- nil variable value
- null variable value
""")
}

