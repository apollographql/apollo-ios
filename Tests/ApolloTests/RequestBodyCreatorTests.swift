//
//  RequestBodyCreatorTests.swift
//  ApolloTests
//
//  Created by Kim de Vos on 16/07/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo
import StarWarsAPI
import UploadAPI

class RequestBodyCreatorTests: XCTestCase {
  private let customRequestBodyCreator = TestCustomRequestBodyCreator()
  private let apolloRequestBodyCreator = ApolloRequestBodyCreator()
  
  // MARK: - Tests
  
  func testRequestBodyWithApolloRequestBodyCreator() {
    let query = HeroNameQuery()
    let req = apolloRequestBodyCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["query"] as? String)
  }

  func testRequestBodyWithCustomRequestBodyCreator() {
    let query = HeroNameQuery()
    let req = customRequestBodyCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["test_query"] as? String)
  }
}
