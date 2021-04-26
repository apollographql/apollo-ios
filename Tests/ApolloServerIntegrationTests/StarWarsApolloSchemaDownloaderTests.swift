//
//  StarWarsApolloSchemaDownloaderTests.swift
//  ApolloServerIntegrationTests
//
//  Created by Anthony Miller on 4/20/21.
//  Copyright © 2021 Apollo GraphQL. All rights reserved.
//

#if os(macOS)
import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class StarWarsApolloSchemaDownloaderTests: XCTestCase {

  func testDownloadingSchemaAsJSON() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()

    let options = ApolloSchemaOptions(downloadMethod: .introspection(endpointURL: TestServerURL.starWarsServer.url),
                                      outputFolderURL: testOutputFolderURL)

    // Delete anything existing at the output URL
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))

    let cliFolderURL = CodegenTestHelper.cliFolderURL()

    _ = try ApolloSchemaDownloader.run(with: cliFolderURL,
                                       options: options)

    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: options.outputURL))

    // Is it non-empty?
    let data = try Data(contentsOf: options.outputURL)
    XCTAssertFalse(data.isEmpty)

    // Is it JSON?
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])

    // Is it schema json?
    _ = try XCTUnwrap(json["__schema"])

    // OK delete it now
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))
  }

  func testDownloadingSchemaInSchemaDefinitionLanguage() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()

    let options = ApolloSchemaOptions(schemaFileType: .schemaDefinitionLanguage,
                                      downloadMethod: .introspection(endpointURL: TestServerURL.starWarsServer.url),
                                      outputFolderURL: testOutputFolderURL)

    // Delete anything existing at the output URL
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))

    let cliFolderURL = CodegenTestHelper.cliFolderURL()

    print(try ApolloSchemaDownloader.run(with: cliFolderURL,
                                         options: options))

    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: options.outputURL))

    // Is it non-empty?
    let data = try Data(contentsOf: options.outputURL)
    XCTAssertFalse(data.isEmpty)

    // It should not be JSON
    XCTAssertNil(try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])

    // OK delete it now
    try FileManager.default.apollo.deleteFile(at: options.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: options.outputURL))
  }

}
#endif
