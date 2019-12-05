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
    let body = requestCreator.requestBody(for: operation, sendOperationIdentifiers: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroName&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D")
  }
  
  func testEncodingQueryWithMoreThanOneParameterIncludingNonHashableValue() throws {
    let operation = HeroNameTypeSpecificConditionalInclusionQuery(episode: .jedi, includeName: true)
    let body = requestCreator.requestBody(for: operation, sendOperationIdentifiers: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if JSONSerialization.dataCanBeSorted() {
      // Here, we know that everything should be encoded in a stable order,
      // and we can check the encoded URL string directly.
          XCTAssertEqual(url?.absoluteString, "http://localhost:8080/graphql?operationName=HeroNameTypeSpecificConditionalInclusion&query=query%20HeroNameTypeSpecificConditionalInclusion($episode:%20Episode,%20$includeName:%20Boolean!)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%20@include(if:%20$includeName)%0A%20%20%20%20...%20on%20Droid%20%7B%0A%20%20%20%20%20%20name%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22JEDI%22,%22includeName%22:true%7D")
    } else {
      // We can't guarantee order of encoding, so we need to pull the JSON back
      // out and check that it has the correct and correctly typed properties.
      let transformedURL = try XCTUnwrap(url,
                                         "URL not created!")
      
      let urlComponents = try XCTUnwrap(URLComponents(url: transformedURL, resolvingAgainstBaseURL: false),
                                        "Couldn't access URL components")
      
      let queryItems = try XCTUnwrap(urlComponents.queryItems,
                                     "No query items!")
      
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
      
      let data = try XCTUnwrap(variables.data(using: .utf8),
                               "Couldn't convert data to UTF8 string!")
      
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
      let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"

      XCTAssertTrue(queryString)
    } else {
      let query = try XCTUnwrap(url?.queryItemDictionary?["query"],
                                "query should not be nil")
      XCTAssertTrue(query == operation.queryDocument)
      
      let variables = try XCTUnwrap(url?.queryItemDictionary?["variables"],
                                    "variables should not nil")
      XCTAssertEqual(variables, "{\"episode\":\"EMPIRE\"}")
      
      guard
        let ext = url?.queryItemDictionary?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      let comparePersistedQuery = try XCTUnwrap(jsonBody["persistedQuery"] as? JSONObject,
                                                "persistedQuery is missing")
      
      let sha256Hash = try XCTUnwrap(comparePersistedQuery["sha256Hash"] as? String,
                                     "sha256Hash is missing")
      
      let version = try XCTUnwrap(comparePersistedQuery["version"] as? Int,
                                  "version is missing")
      
      XCTAssertEqual(version, 1)
      XCTAssertEqual(sha256Hash, "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
      let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&variables=%7B%22episode%22:%22EMPIRE%22%7D"
      XCTAssertTrue(queryString)
    } else {

      let variables = try XCTUnwrap(url?.queryItemDictionary?["variables"],
                                    "variables should not nil")

      XCTAssertEqual(variables, "{\"episode\":\"EMPIRE\"}")
      
      guard
        let ext = url?.queryItemDictionary?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      let comparePersistedQuery = try XCTUnwrap(jsonBody["persistedQuery"] as? JSONObject,
                                                "persistedQuery is missing")
      
      let sha256Hash = try XCTUnwrap(comparePersistedQuery["sha256Hash"] as? String,
                                     "sha256Hash is missing")
      
      let version = try XCTUnwrap(comparePersistedQuery["version"] as? Int,
                                  "version is missing")
      
      XCTAssertEqual(version, 1)
      XCTAssertEqual(sha256Hash, "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
  }
  
  func testEncodingQueryWithNullDefaultParameter() {
    let operation = HeroNameQuery()
    let body = requestCreator.requestBody(for: operation, sendOperationIdentifiers: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
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
    
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    
    let url = transformer.createGetURL()
    
    if #available(iOS 11, macOS 13, watchOS 4, tvOS 11, *) {
    let queryString = url?.absoluteString == "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%22f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671%22,%22version%22:1%7D%7D&query=query%20HeroName($episode:%20Episode)%20%7B%0A%20%20hero(episode:%20$episode)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22episode%22:null%7D"
      XCTAssertTrue(queryString)
    } else {
      let variables = try XCTUnwrap(url?.queryItemDictionary?["variables"],
                                    "variables should not nil")
      XCTAssertEqual(variables, "{\"episode\":null}")
      
      guard
        let ext = url?.queryItemDictionary?["extensions"],
        let data = ext.data(using: .utf8),
        let jsonBody = try? JSONSerializationFormat.deserialize(data: data) as? JSONObject
        else {
          XCTFail("extensions json data should not be nil")
          return
      }
      
      let comparePersistedQuery = try XCTUnwrap(jsonBody["persistedQuery"] as? JSONObject,
                                                "persistedQuery is missing")
      
      let sha256Hash = try XCTUnwrap(comparePersistedQuery["sha256Hash"] as? String,
                                     "sha256Hash is missing")
      
      let version = try XCTUnwrap(comparePersistedQuery["version"] as? Int,
                                  "version is missing")
      
      XCTAssertEqual(version, 1)
      XCTAssertEqual(sha256Hash, "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671")
    }
  }
}
