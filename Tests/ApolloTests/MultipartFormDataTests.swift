//
//  MultipartFormDataTests.swift
//  Apollo
//
//  Created by Ellen Shapiro on 9/21/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import Apollo
import ApolloTestSupport

class MultipartFormDataTests: XCTestCase {
  func testSingleFile() throws {
    let alphaFileUrl = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
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

    let stringToCompare = try formData.toTestString()
    XCTAssertEqual(stringToCompare, expectedString)
  }
  
  func testMultifileFile() throws {
    let bravoFileUrl = TestFileHelper.fileURLForFile(named: "b", extension: "txt")
    let charlieFileUrl = TestFileHelper.fileURLForFile(named: "c", extension: "txt")
    
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
    let stringToCompare = try formData.toTestString()
    XCTAssertEqual(stringToCompare, expectedString)
  }
  
  func testBatchFile() throws {
    let alphaFileUrl = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
    let bravoFileUrl = TestFileHelper.fileURLForFile(named: "b", extension: "txt")
    let charlieFileUrl = TestFileHelper.fileURLForFile(named: "c", extension: "txt")
    
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

    let stringToCompare = try formData.toTestString()
    XCTAssertEqual(stringToCompare, expectedString)
  }
}
