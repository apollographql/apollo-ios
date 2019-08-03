//
//  GETTransformerTests.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 7/1/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import Apollo
import StarWarsAPI

class GETTransformerTests: XCTestCase {
  
  private lazy var url = URL(string: "http://localhost:8080/graphql")!
  
  func testEncodingQueryWithSingleParameter() {
    let operation = HeroNameQuery(episode: .empire)
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }
  
  func testEncodingQueryWithNullDefaultParameter() {
    let operation = HeroNameQuery()
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D")
  }
  
  func testMissingQueryParameterInBodyReturnsNil() {
    let operation = HeroNameQuery(episode: .empire)
    let body: GraphQLMap = [
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    XCTAssertNil(url)
  }
}
