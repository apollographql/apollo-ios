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

  func testDownloadingSchemaInSchemaDefinitionLanguage() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: TestServerURL.starWarsServer.url),
                                                          outputFolderURL: testOutputFolderURL)

    // Delete anything existing at the output URL
    try FileManager.default.apollo.deleteFile(at: configuration.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    print(try ApolloSchemaDownloader.fetch(with: configuration))

    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    // Is it non-empty?
    let data = try Data(contentsOf: configuration.outputURL)
    XCTAssertFalse(data.isEmpty)

    // It should not be JSON
    XCTAssertNil(try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])

    // OK delete it now
    try FileManager.default.apollo.deleteFile(at: configuration.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: configuration.outputURL))
  }

}
#endif
