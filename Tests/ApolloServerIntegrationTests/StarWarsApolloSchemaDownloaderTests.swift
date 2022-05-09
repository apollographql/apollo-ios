#if os(macOS)
import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class StarWarsApolloSchemaDownloaderTests: XCTestCase {

  func testDownloadingSchema_usingIntrospection_shouldOutputSDL() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: TestServerURL.starWarsServer.url),
                                                          outputFolderURL: testOutputFolderURL)

    // Delete anything existing at the output URL
    try FileManager.default.apollo.delete(at: configuration.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    try ApolloSchemaDownloader.fetch(with: configuration)

    // Does the file now exist?
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    // Is it non-empty?
    let data = try Data(contentsOf: configuration.outputURL)
    XCTAssertFalse(data.isEmpty)

    // It should not be JSON
    XCTAssertNil(try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])

    // Can it be turned into the expected schema?
    let frontend = try ApolloCodegenFrontend()
    let source = try frontend.makeSource(from: configuration.outputURL)
    let schema = try frontend.loadSchemaFromSDL(source)
    let episodeType = try schema.getType(named: "Episode")
    XCTAssertEqual(episodeType?.name, "Episode")

    // OK delete it now
    try FileManager.default.apollo.delete(at: configuration.outputURL)
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: configuration.outputURL))
  }

}
#endif
