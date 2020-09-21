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

  // MARK: - Custom request creator tests

  func testSingleFileWithCustomRequestCreator() throws {
    let alphaFileUrl = self.fileURLForFile(named: "a", extension: "txt")

    let alphaFile = try GraphQLFile(fieldName: "upload",
                                    originalName: "a.txt",
                                    mimeType: "text/plain",
                                    fileURL: alphaFileUrl)

    let data = try customRequestCreator.requestMultipartFormData(
      for: UploadOneFileMutation(file: alphaFile.originalName),
      files: [alphaFile],
      sendOperationIdentifiers: false,
      serializationFormat: JSONSerializationFormat.self,
      manualBoundary: "TEST.BOUNDARY"
    )

    let stringToCompare = try self.string(from: data)

    // Operation parameters may be in weird order, so let's at least check that the files and single parameter got encoded properly.
      let expectedEndString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="upload"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY--
"""

    let expectedQueryString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="test_query"

mutation UploadOneFile($file: Upload!) {
  singleUpload(file: $file) {
    __typename
    id
    path
    filename
    mimetype
  }
}
"""
    self.checkString(stringToCompare, includes: expectedEndString)
    self.checkString(stringToCompare, includes: expectedQueryString)
  }

  func testRequestBodyWithCustomRequestCreator() {
    let query = HeroNameQuery()
    let req = customRequestCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["test_query"] as? String)
  }
}
