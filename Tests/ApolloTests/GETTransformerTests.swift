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
    
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"
    
    XCTAssertTrue(queryString)
  }
  
  func testEncodingQueryWithMoreThanOneParameterIncludingNonHashableValue() {
    let operation = HeroNameTypeSpecificConditionalInclusionQuery(episode: .jedi, includeName: true)
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, tvOS 11, watchOS 4, *) {
      // Here, we know that everything should be encoded in a stable order,
      // and we can check the encoded URL string directly.
          XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?query=query%20HeroNameTypeSpecificConditionalInclusion($episode:%20Episode,%20$includeName:%20Boolean!)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%20@include(if:%20$includeName)%0A%20%20%20%20...%20on%20Droid%20%7B%0A%20%20%20%20%20%20name%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22JEDI%22,%22includeName%22:true%7D")
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
  
  func testEncodingQueryWith2DParameter() {
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
      let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"

      XCTAssertTrue(queryString)
    } else {
      guard let query = url?.queryItems?["query"] else {
        XCTFail("query should not nil")
        return
      }
      XCTAssertTrue(query == operation.queryDocument)
      
      guard let variables = url?.queryItems?["variables"] else {
        XCTFail("variables should not nil")
        return
      }
      XCTAssert(variables == "{\"episode\":\"EMPIRE\"}")
      
      guard let ext = url?.queryItems?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      guard let comparePersistedQuery = jsonBody["persistedQuery"] as? JSONObject else {
        XCTFail("persistedQuery is missing")
        return
      }
      
      guard let sha256Hash = comparePersistedQuery["sha256Hash"] as? String else {
        XCTFail("sha256Hash is missing")
        return
      }
      
      guard let version = comparePersistedQuery["version"] as? Int else {
        XCTFail("version is missing")
        return
      }
      
      XCTAssert(version == 1)
      XCTAssert(sha256Hash == "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
  }
  
  func testEncodingQueryWith2DWOQueryParameter() {
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
      let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"
      XCTAssertTrue(queryString)
    } else {

      guard let variables = url?.queryItems?["variables"] else {
        XCTFail("variables should not nil")
        return
      }
      XCTAssert(variables == "{\"episode\":\"EMPIRE\"}")
      
      guard let ext = url?.queryItems?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      guard let comparePersistedQuery = jsonBody["persistedQuery"] as? JSONObject else {
        XCTFail("persistedQuery is missing")
        return
      }
      
      guard let sha256Hash = comparePersistedQuery["sha256Hash"] as? String else {
        XCTFail("sha256Hash is missing")
        return
      }
      
      guard let version = comparePersistedQuery["version"] as? Int else {
        XCTFail("version is missing")
        return
      }
      
      XCTAssert(version == 1)
      XCTAssert(sha256Hash == "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
  }
  
  func testEncodingQueryWithNullDefaultParameter() {
    let operation = HeroNameQuery()
    let body: GraphQLMap = [
      "query": operation.queryDocument,
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D"
    
    XCTAssertTrue(queryString)
  }
  
  func testEncodingQueryWith2DNullDefaultParameter() {
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D"
      XCTAssertTrue(queryString)
    } else {
      guard let variables = url?.queryItems?["variables"] else {
        XCTFail("variables should not nil")
        return
      }
      XCTAssert(variables == "{\"episode\":null}")
      
      guard let ext = url?.queryItems?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      guard let comparePersistedQuery = jsonBody["persistedQuery"] as? JSONObject else {
        XCTFail("persistedQuery is missing")
        return
      }
      
      guard let sha256Hash = comparePersistedQuery["sha256Hash"] as? String else {
        XCTFail("sha256Hash is missing")
        return
      }
      
      guard let version = comparePersistedQuery["version"] as? Int else {
        XCTFail("version is missing")
        return
      }
      
      XCTAssert(version == 1)
      XCTAssert(sha256Hash == "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
  }
  
  func testMissingQueryParameterInBodyReturnsNil() {
    let operation = HeroNameQuery(episode: .empire)
    let body: GraphQLMap = [
      "variables": operation.variables,
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }
}
