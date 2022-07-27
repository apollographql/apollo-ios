#if os(macOS)
import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class SchemaRegistryApolloSchemaDownloaderTests: XCTestCase {
  func testDownloadingSchema_fromSchemaRegistry_shouldOutputSDL() throws {
    let testOutputFolderURL = CodegenTestHelper.outputFolderURL()
    XCTAssertFalse(ApolloFileManager.default.doesFileExist(atPath: testOutputFolderURL.path))

    guard let apiKey = ProcessInfo.processInfo.environment["REGISTRY_API_KEY"] else {
     throw XCTSkip("No API key could be fetched from the environment to test downloading from the schema registry")
    }

    let settings = ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings(
      apiKey: apiKey,
      graphID: "Apollo-Fullstack-8zo5jl"
    )
    let configuration = ApolloSchemaDownloadConfiguration(
      using: .apolloRegistry(settings),
      outputPath: CodegenTestHelper.schemaFolderURL().path
    )

    try ApolloSchemaDownloader.fetch(configuration: configuration)
    XCTAssertTrue(ApolloFileManager.default.doesFileExist(atPath: configuration.outputPath))

    // Can it be turned into the expected schema?
    let frontend = try GraphQLJSFrontend()
    let source = try frontend.makeSource(from: URL(fileURLWithPath: configuration.outputPath))
    let schema = try frontend.loadSchema(from: [source])
    let rocketType = try schema.getType(named: "Rocket")
    XCTAssertEqual(rocketType?.name, "Rocket")
  }
}
#endif
