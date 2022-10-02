#if os(macOS)
import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class StarWarsApolloSchemaDownloaderTests: XCTestCase {

  func testDownloadingSchema_usingIntrospection_shouldOutputSDL() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    let configuration = ApolloSchemaDownloadConfiguration(
      using: .introspection(endpointURL: TestServerURL.starWarsServer.url),
      outputPath: testOutputFolderURL.path
    )

    // Delete anything existing at the output URL
    try ApolloFileManager.default.deleteDirectory(atPath: configuration.outputPath)
    XCTAssertFalse(ApolloFileManager.default.doesFileExist(atPath: configuration.outputPath))

    try ApolloSchemaDownloader.fetch(configuration: configuration)

    // Does the file now exist?
    XCTAssertTrue(ApolloFileManager.default.doesFileExist(atPath: configuration.outputPath))

    // Is it non-empty?
    let data = try Data(contentsOf: URL(fileURLWithPath: configuration.outputPath))
    XCTAssertFalse(data.isEmpty)

    // It should not be JSON
    XCTAssertNil(try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable:Any])

    // Can it be turned into the expected schema?
    let frontend = try GraphQLJSFrontend()
    let source = try frontend.makeSource(from: URL(fileURLWithPath: configuration.outputPath))
    let schema = try frontend.loadSchema(from: [source])
    let episodeType = try schema.getType(named: "Episode")
    XCTAssertEqual(episodeType?.name, "Episode")

    // OK delete it now
    try ApolloFileManager.default.deleteFile(atPath: configuration.outputPath)
    XCTAssertFalse(ApolloFileManager.default.doesFileExist(atPath: configuration.outputPath))
  }

}
#endif
