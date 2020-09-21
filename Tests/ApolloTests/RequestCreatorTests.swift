//
//  MultipartFormDataTests.swift
//  ApolloTests
//
//  Created by Kim de Vos on 16/07/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo
import StarWarsAPI
import UploadAPI

class RequestCreatorTests: XCTestCase {
  private let customRequestCreator = TestCustomRequestCreator()
  private let apolloRequestCreator = ApolloRequestCreator()
  
  // MARK: - Tests
  
  func testRequestBodyWithApolloRequestCreator() {
    let query = HeroNameQuery()
    let req = apolloRequestCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["query"] as? String)
  }

  func testRequestBodyWithCustomRequestCreator() {
    let query = HeroNameQuery()
    let req = customRequestCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["test_query"] as? String)
  }
}
