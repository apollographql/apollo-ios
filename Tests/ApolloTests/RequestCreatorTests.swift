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

class RequestCreatorTests: XCTestCase {
  private let customRequestCreator = TestCustomRequestCreator()
  private let apolloRequestCreator = ApolloRequestCreator()

  private func testParentFolder(for file: StaticString = #file) -> URL {
    let fileAsString = file.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
    let url = URL(fileURLWithPath: fileAsString)
    return url.deletingLastPathComponent()
  }
    
  private func checkString(_ string: String,
                           includes expectedString: String,
                           file: StaticString = #file,
                           line: UInt = #line) {
    XCTAssertTrue(string.contains(expectedString),
                  "Expected string:\n\n\(expectedString)\n\ndid not appear in string\n\n\(string)",
      file: file,
      line: line)
  }
  
  private func string(from formData: MultipartFormData) throws -> String {
    let encodedData = try formData.encode()
    let string = String(bytes: encodedData, encoding: .utf8)!
  
    // Replacing CRLF with new line as string literals uses new lines
    return string.replacingOccurrences(of: MultipartFormData.CRLF, with: "\n")
  }
  
  private func fileURLForFile(named name: String, extension fileExtension: String) -> URL {
    return self.testParentFolder()
        .appendingPathComponent(name)
        .appendingPathExtension(fileExtension)
  }
  
  // MARK: - Tests
  
  func testSingleFile() throws {
    let alphaFileUrl = self.fileURLForFile(named: "a", extension: "txt")
    let alphaData = try Data(contentsOf: alphaFileUrl)
    
    let formData = MultipartFormData(boundary: "------------------------cec8e8123c05ba25")
    try formData.appendPart(string: "{ \"query\": \"mutation ($file: Upload!) { singleUpload(file: $file) { id } }\", \"variables\": { \"file\": null } }", name: "operations")
    try formData.appendPart(string: "{ \"0\": [\"variables.file\"] }", name: "map")
    formData.appendPart(data: alphaData, name: "0", contentType: "text/plain", filename: "a.txt")
    
    let expectedString = """
--------------------------cec8e8123c05ba25
Content-Disposition: form-data; name="operations"

{ "query": "mutation ($file: Upload!) { singleUpload(file: $file) { id } }", "variables": { "file": null } }
--------------------------cec8e8123c05ba25
Content-Disposition: form-data; name="map"

{ "0": ["variables.file"] }
--------------------------cec8e8123c05ba25
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--------------------------cec8e8123c05ba25--
"""

    let stringToCompare = try self.string(from: formData)
    XCTAssertEqual(stringToCompare, expectedString)
  }
  
  func testMultifileFile() throws {
    let bravoFileUrl = self.fileURLForFile(named: "b", extension: "txt")
    let charlieFileUrl = self.fileURLForFile(named: "c", extension: "txt")
    
    let bravoData = try Data(contentsOf: bravoFileUrl)
    let charlieData = try Data(contentsOf: charlieFileUrl)
    
    let formData = MultipartFormData(boundary: "------------------------ec62457de6331cad")
    try formData.appendPart(string: "{ \"query\": \"mutation($files: [Upload!]!) { multipleUpload(files: $files) { id } }\", \"variables\": { \"files\": [null, null] } }", name: "operations")
    try formData.appendPart(string: "{ \"0\": [\"variables.files.0\"], \"1\": [\"variables.files.1\"] }", name: "map")
    formData.appendPart(data: bravoData, name: "0", contentType: "text/plain", filename: "b.txt")
    formData.appendPart(data: charlieData, name: "1", contentType: "text/plain", filename: "c.txt")
    
    let expectedString = """
--------------------------ec62457de6331cad
Content-Disposition: form-data; name="operations"

{ "query": "mutation($files: [Upload!]!) { multipleUpload(files: $files) { id } }", "variables": { "files": [null, null] } }
--------------------------ec62457de6331cad
Content-Disposition: form-data; name="map"

{ "0": ["variables.files.0"], "1": ["variables.files.1"] }
--------------------------ec62457de6331cad
Content-Disposition: form-data; name="0"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--------------------------ec62457de6331cad
Content-Disposition: form-data; name="1"; filename="c.txt"
Content-Type: text/plain

Charlie file content.

--------------------------ec62457de6331cad--
"""
    let stringToCompare = try self.string(from: formData)
    XCTAssertEqual(stringToCompare, expectedString)
  }
  
  func testBatchFile() throws {
    let alphaFileUrl = self.fileURLForFile(named: "a", extension: "txt")
    let bravoFileUrl = self.fileURLForFile(named: "b", extension: "txt")
    let charlieFileUrl = self.fileURLForFile(named: "c", extension: "txt")
    
    let alphaData = try Data(contentsOf: alphaFileUrl)
    let bravoData = try Data(contentsOf: bravoFileUrl)
    let charlieData = try Data(contentsOf: charlieFileUrl)
    
    let formData = MultipartFormData(boundary: "------------------------627436eaefdbc285")
    try formData.appendPart(string: "[{ \"query\": \"mutation ($file: Upload!) { singleUpload(file: $file) { id } }\", \"variables\": { \"file\": null } }, { \"query\": \"mutation($files: [Upload!]!) { multipleUpload(files: $files) { id } }\", \"variables\": { \"files\": [null, null] } }]", name: "operations")
    try formData.appendPart(string: "{ \"0\": [\"0.variables.file\"], \"1\": [\"1.variables.files.0\"], \"2\": [\"1.variables.files.1\"] }", name: "map")
    formData.appendPart(data: alphaData, name: "0", contentType: "text/plain", filename: "a.txt")
    formData.appendPart(data: bravoData, name: "1", contentType: "text/plain", filename: "b.txt")
    formData.appendPart(data: charlieData, name: "2", contentType: "text/plain", filename: "c.txt")
    
    let expectedString = """
--------------------------627436eaefdbc285
Content-Disposition: form-data; name="operations"

[{ "query": "mutation ($file: Upload!) { singleUpload(file: $file) { id } }", "variables": { "file": null } }, { "query": "mutation($files: [Upload!]!) { multipleUpload(files: $files) { id } }", "variables": { "files": [null, null] } }]
--------------------------627436eaefdbc285
Content-Disposition: form-data; name="map"

{ "0": ["0.variables.file"], "1": ["1.variables.files.0"], "2": ["1.variables.files.1"] }
--------------------------627436eaefdbc285
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--------------------------627436eaefdbc285
Content-Disposition: form-data; name="1"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--------------------------627436eaefdbc285
Content-Disposition: form-data; name="2"; filename="c.txt"
Content-Type: text/plain

Charlie file content.

--------------------------627436eaefdbc285--
"""

    let stringToCompare = try self.string(from: formData)
    XCTAssertEqual(stringToCompare, expectedString)
  }
  
  func testSingleFileWithApolloRequestCreator() throws {
    let alphaFileUrl = self.fileURLForFile(named: "a", extension: "txt")
    
    let alphaFile = GraphQLFile(fieldName: "upload",
                                originalName: "a.txt",
                                mimeType: "text/plain",
                                fileURL: alphaFileUrl)
    
    let data = try apolloRequestCreator.requestMultipartFormData(
      for: HeroNameQuery(),
      files: [alphaFile!],
      sendOperationIdentifiers: false,
      serializationFormat: JSONSerializationFormat.self,
      manualBoundary: "TEST.BOUNDARY"
    )
    
    let stringToCompare = try self.string(from: data)
    
    if JSONSerialization.dataCanBeSorted() {
      let expectedString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="operations"

{"operationName":"HeroName","query":"query HeroName($episode: Episode) {\\n  hero(episode: $episode) {\\n    __typename\\n    name\\n  }\\n}","variables":{"episode":null,"upload":null}}
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.upload"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY--
"""
      XCTAssertEqual(stringToCompare, expectedString)
    } else {
      // Operation parameters may be in weird order, so let's at least check that the files and single parameter got encoded properly.
      let expectedEndString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.upload"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY--
"""
      self.checkString(stringToCompare, includes: expectedEndString)
    }
  }

  func testMultipleFilesWithApolloRequestCreator() throws {
    let alphaFileURL = self.fileURLForFile(named: "a", extension: "txt")
    let alphaFile = GraphQLFile(fieldName: "uploads",
                                originalName: "a.txt",
                                mimeType: "text/plain",
                                fileURL: alphaFileURL)!
    
    let betaFileURL = self.fileURLForFile(named: "b", extension: "txt")
    let betaFile = GraphQLFile(fieldName: "uploads",
                               originalName: "b.txt",
                               mimeType: "text/plain",
                               fileURL: betaFileURL)!
    
    
    let data = try apolloRequestCreator.requestMultipartFormData(
      for: HeroNameQuery(),
      files: [alphaFile, betaFile],
      sendOperationIdentifiers: false,
      serializationFormat: JSONSerializationFormat.self,
      manualBoundary: "TEST.BOUNDARY"
    )
    
    let stringToCompare = try self.string(from: data)
    
    if JSONSerialization.dataCanBeSorted() {
      let expectedString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="operations"

{"operationName":"HeroName","query":"query HeroName($episode: Episode) {\\n  hero(episode: $episode) {\\n    __typename\\n    name\\n  }\\n}","variables":{"episode":null,\"uploads\":null}}
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.uploads.0"],"1":["variables.uploads.1"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY
Content-Disposition: form-data; name="1"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--TEST.BOUNDARY--
"""
      XCTAssertEqual(stringToCompare, expectedString)
    } else {
      // Query and operation parameters may be in weird order, so let's at least check that the files got encoded properly.
      let endString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY
Content-Disposition: form-data; name="1"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--TEST.BOUNDARY--
"""
      self.checkString(stringToCompare, includes: endString)
    }
  }

  func testRequestBodyWithApolloRequestCreator() {
    let query = HeroNameQuery()
    let req = apolloRequestCreator.requestBody(for: query, sendOperationIdentifiers: false)

    XCTAssertEqual(query.queryDocument, req["query"] as? String)
  }

  // MARK: - Custom request creator tests

  func testSingleFileWithCustomRequestCreator() throws {
    let alphaFileUrl = self.fileURLForFile(named: "a", extension: "txt")

    let alphaFile = GraphQLFile(fieldName: "upload",
                                originalName: "a.txt",
                                mimeType: "text/plain",
                                fileURL: alphaFileUrl)

    let data = try customRequestCreator.requestMultipartFormData(
      for: HeroNameQuery(),
      files: [alphaFile!],
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

query HeroName($episode: Episode) {
  hero(episode: $episode) {
    __typename
    name
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
