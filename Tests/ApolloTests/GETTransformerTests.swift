//
//  GETTransformerTests.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 7/1/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class GETTransformerTests: XCTestCase {
  private var requestBodyCreator: ApolloRequestBodyCreator!
  private static let url = TestURL.mockPort8080.url

  override func setUp() {
    super.setUp()

    requestBodyCreator = ApolloRequestBodyCreator()
  }

  override func tearDown() {
    requestBodyCreator = nil

    super.tearDown()
  }
  
  func testEncodingQueryWithSingleParameter() {
    let operation = HeroNameQuery(episode: .empire)
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: false,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }
  
  func testEncodingQueryWithMoreThanOneParameterIncludingNonHashableValue() throws {
    let operation = HeroNameTypeSpecificConditionalInclusionQuery(episode: .jedi, includeName: true)
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: false,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    // Here, we know that everything should be encoded in a stable order,
    // and we can check the encoded URL string directly.
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroNameTypeSpecificConditionalInclusion&query=query%20HeroNameTypeSpecificConditionalInclusion($episode:%20Episode,%20$includeName:%20Boolean!)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%20@include(if:%20$includeName)%0A%20%20%20%20...%20on%20Droid%20%7B%0A%20%20%20%20%20%20__typename%0A%20%20%20%20%20%20name%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22JEDI%22,%22includeName%22:true%7D")
  }
  
  func testEncodingQueryWith2DParameter() throws {
    let operation = HeroNameQuery(episode: .empire)
    
    let persistedQuery: GraphQLMap = [
      "version": 1,
      "sha256Hash": operation.operationIdentifier
    ]
    
    let extensions: GraphQLMap = [
      "persistedQuery": persistedQuery
    ]
    
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
      "extensions": extensions
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"
    
    XCTAssertTrue(queryString)
  }

  func testEncodingQueryWithParameterWithPlusSignEncoded() throws {
    let operation = HeroNameQuery(episode: .empire)

    let extensions: GraphQLMap = [
      "testParam": "+Test+Test"
    ]

    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
      "extensions": extensions
    ]

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?extensions=%7B%22testParam%22:%22%2BTest%2BTest%22%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"

    XCTAssertEqual(url?.absoluteString, expected)
  }

  func testEncodingQueryWithParameterWithAmpersandEncoded() throws {
    let operation = HeroNameQuery(episode: .empire)

    let extensions: GraphQLMap = [
      "testParam": "Test&Test"
    ]

    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
      "extensions": extensions
    ]

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?extensions=%7B%22testParam%22:%22Test%26Test%22%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"

    XCTAssertEqual(url?.absoluteString, expected)
  }
  
  func testEncodingQueryWith2DWOQueryParameter() throws {
    let operation = HeroNameQuery(episode: .empire)
    
    let persistedQuery: GraphQLMap = [
      "version": 1,
      "sha256Hash": operation.operationIdentifier
    ]
    
    let extensions: GraphQLMap = [
      "persistedQuery": persistedQuery
    ]
    
    let body: GraphQLMap = [
      "variables": operation.variables,
      "extensions": extensions
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"
    XCTAssertTrue(queryString)
  }
  
  func testEncodingQueryWithNullDefaultParameter() {
    let operation = HeroNameQuery()
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: false,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D")
  }
  
  func testEncodingQueryWith2DNullDefaultParameter() throws {
    let operation = HeroNameQuery()
    
    let persistedQuery: GraphQLMap = [
      "version": 1,
      "sha256Hash": operation.operationIdentifier
    ]
    
    let extensions: GraphQLMap = [
      "persistedQuery": persistedQuery
    ]
    
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
      "extensions": extensions
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D"
    XCTAssertTrue(queryString)
  }

  func testEncodingQueryWithExistingParameters() throws {
    let operation = HeroNameQuery(episode: .empire)
    let body = requestBodyCreator.requestBody(for: operation,
                                              sendOperationIdentifiers: false,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)

    var components = URLComponents(string: Self.url.absoluteString)!
    components.queryItems = [URLQueryItem(name: "foo", value: "bar")]

    let transformer = GraphQLGETTransformer(body: body, url: components.url!)

    let url = transformer.createGetURL()

    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?foo=bar&operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }

	func testEncodingWithEmptyQueryParameter() throws {
		let body: GraphQLMap = ["variables": nil]
		let transformer = GraphQLGETTransformer(body: body, url: Self.url)
		let url = transformer.createGetURL()

		XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql")
	}
}
