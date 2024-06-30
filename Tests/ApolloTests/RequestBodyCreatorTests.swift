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
  
  func create<Operation: GraphQLOperation>(with creator: RequestBodyCreator, for query: Operation) -> GraphQLMap {
    creator.requestBody(for: query,
                        sendOperationIdentifiers: false,
                        sendQueryDocument: true,
                        autoPersistQuery: false)
  }
  
  // MARK: - Tests
  
  func testRequestBodyWithApolloRequestBodyCreator() {
    let query = HeroNameQuery()
    let req = self.create(with: apolloRequestBodyCreator, for: query)

    XCTAssertEqual(query.queryDocument, req["query"] as? String)
  }

  func testRequestBodyWithCustomRequestBodyCreator() {
    let query = HeroNameQuery()
    let req = self.create(with: customRequestBodyCreator, for: query)

    XCTAssertEqual(query.queryDocument, req["test_query"] as? String)
  }

  func testRequestBodyOmitsVariablesFieldWhenValuesAreNil() {
    let query = HeroNameQuery(episode: nil)
    let req = self.create(with: apolloRequestBodyCreator, for: query)

    XCTAssertFalse(req.keys.contains(where: { $0 == "variables" }))
  }

  func testRequestBodyIncludesVariablesFieldWhenItContainsNonNilValues() {
    let episode = Episode.empire
    let query = HeroNameQuery(episode: episode)
    let req = self.create(with: apolloRequestBodyCreator, for: query)

    XCTAssertEqual(req["variables"], ["episode": episode.rawValue])
  }
}
