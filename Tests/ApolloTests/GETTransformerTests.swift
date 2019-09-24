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
  private let requestCreator = ApolloRequestCreator()
  private lazy var url = URL(string: "http://localhost:8080/graphql")!
  
  func testEncodingQueryWithSingleParameter() {
    let operation = HeroNameQuery(episode: .empire)
    let body = requestCreator.requestBody(for: operation)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%20hero(episode:%20$episode)%20%7B%20__typename%20name%20%7D%20%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }
  
  func testEncodingQueryWithMoreThanOneParameterIncludingNonHashableValue() {
    let operation = HeroNameTypeSpecificConditionalInclusionQuery(episode: .jedi, includeName: true)
    let body = requestCreator.requestBody(for: operation)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, tvOS 11, watchOS 4, *) {
      // Here, we know that everything should be encoded in a stable order,
      // and we can check the encoded URL string directly.
          XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroNameTypeSpecificConditionalInclusion&query=query%20HeroNameTypeSpecificConditionalInclusion($episode:%20Episode,%20$includeName:%20Boolean!)%20%7B%20hero(episode:%20$episode)%20%7B%20__typename%20name%20@include(if:%20$includeName)%20...%20on%20Droid%20%7B%20name%20%7D%20%7D%20%7D&variables=%7B%22episode%22:%22JEDI%22,%22includeName%22:true%7D")
    } else {
      // We can't guarantee order of encoding, so we need to pull the JSON back
      // out and check that it has the correct and correctly typed properties.
      guard let transformedURL = url else {
        XCTFail("URL not created!")
        return
      }
      
      guard let urlComponents = URLComponents(url: transformedURL, resolvingAgainstBaseURL: false) else {
        XCTFail("Couldn't access URL components")
        return
      }
      
      guard let queryItems = urlComponents.queryItems else {
        XCTFail("No query items!")
        return
      }
      
      guard
        let operationNameItem = queryItems.first(where: { $0.name == "operationName" }),
        let operationName = operationNameItem.value else {
          XCTFail("Query items did not contain operation name!")
          return
      }
      
      XCTAssertEqual(operationName, "HeroNameTypeSpecificConditionalInclusion")
      
      guard
        let variablesQueryItem = queryItems.first(where: { $0.name == "variables" }),
        let variables = variablesQueryItem.value else {
          XCTFail("Query items did not contain variables!")
          return
      }
      
      guard let data = variables.data(using: .utf8) else {
        XCTFail("Couldn't convert data to UTF8 string!")
        return
      }
      
      guard
        let object = try? JSONSerialization.jsonObject(with: data),
        let dict = object as? [String: Any] else {
          XCTFail("Couldn't get dictionary out of json!")
          return
      }
      
      XCTAssertEqual(dict["includeName"] as? Bool, true)
      XCTAssertEqual(dict["episode"] as? String, "JEDI")
    }
  }
  
  func testEncodingQueryWithNullDefaultParameter() {
    let operation = HeroNameQuery()
    let body = requestCreator.requestBody(for: operation)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%20hero(episode:%20$episode)%20%7B%20__typename%20name%20%7D%20%7D&variables=%7B%22episode%22:null%7D")
  }
}
