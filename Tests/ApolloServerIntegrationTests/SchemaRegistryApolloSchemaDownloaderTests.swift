#if os(macOS)
import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class SchemaRegistryApolloSchemaDownloaderTests: XCTestCase {
  func testDownloadingSchema_fromSchemaRegistry_shouldOutputSDL() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    XCTAssertFalse(FileManager.default.apollo.fileExists(at: testOutputFolderURL))

    guard let apiKey = ProcessInfo.processInfo.environment["REGISTRY_API_KEY"] else {
     throw XCTSkip("No API key could be fetched from the environment to test downloading from the schema registry")
    }

    let settings = ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings(apiKey: apiKey, graphID: "Apollo-Fullstack-8zo5jl")
    let configuration = ApolloSchemaDownloadConfiguration(using: .apolloRegistry(settings),
                                                          outputFolderURL: CodegenTestHelper.schemaFolderURL())

    try ApolloSchemaDownloader.fetch(with: configuration)
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    // Can it be turned into the expected schema?
    let frontend = try ApolloCodegenFrontend()
    let source = try frontend.makeSource(from: configuration.outputURL)
    let schema = try frontend.loadSchemaFromSDL(source)
    let rocketType = try schema.getType(named: "Rocket")
    XCTAssertEqual(rocketType?.name, "Rocket")
  }
}
#endif
