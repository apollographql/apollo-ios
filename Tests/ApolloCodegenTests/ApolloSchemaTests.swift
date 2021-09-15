import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class ApolloSchemaTests: XCTestCase {
  private var defaultOutputURL: URL {
    return CodegenTestHelper.outputFolderURL()
      .appendingPathComponent("schema.graphqls")
  }

  func testCreatingSchemaDownloadConfiguration_forIntrospectionDownload_usingDefaultParameters() throws {
    let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: TestURL.mockPort8080.url),
                                                          outputFolderURL: CodegenTestHelper.outputFolderURL())

    XCTAssertEqual(configuration.downloadMethod, .introspection(endpointURL: TestURL.mockPort8080.url))
    XCTAssertEqual(configuration.outputURL, self.defaultOutputURL)
    XCTAssertTrue(configuration.headers.isEmpty)
  }

  func testCreatingSchemaDownloadConfiguration_forRegistryDownload_usingDefaultParameters() throws {
    let settings = ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings(apiKey: "Fake_API_Key",
                                                                                           graphID: "Fake_Graph_ID")
    let configuration = ApolloSchemaDownloadConfiguration(using: .apolloRegistry(settings),
                                                          outputFolderURL: CodegenTestHelper.outputFolderURL())

    XCTAssertEqual(configuration.downloadMethod, .apolloRegistry(settings))
    XCTAssertEqual(configuration.outputURL, self.defaultOutputURL)
    XCTAssertTrue(configuration.headers.isEmpty)
  }

  func testCreatingSchemaDownloadConfiguration_forRegistryDownload_usingAllParameters() throws {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let settings = ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings(apiKey: "Fake_API_Key",
                                                                                           graphID: "Fake_Graph_ID",
                                                                                           variant: "Fake_Variant")
    let headers = [
      ApolloSchemaDownloadConfiguration.HTTPHeader(key: "Authorization", value: "Bearer tokenGoesHere"),
      ApolloSchemaDownloadConfiguration.HTTPHeader(key: "Custom-Header",  value: "Custom_Customer")
    ]

    let schemaFileName = "different_name"
    let configuration = ApolloSchemaDownloadConfiguration(using: .apolloRegistry(settings),
                                                          headers: headers,
                                                          outputFolderURL: sourceRoot,
                                                          schemaFilename: schemaFileName)

    XCTAssertEqual(configuration.downloadMethod, .apolloRegistry(settings))
    XCTAssertEqual(configuration.headers, headers)

    let expectedOutputURL = sourceRoot.appendingPathComponent("\(schemaFileName).graphqls")
    XCTAssertEqual(configuration.outputURL, expectedOutputURL)
  }

  func testFormatConversion_givenIntrospectionJSON_shouldOutputValidSDL() throws {
    let bundle = Bundle(for: type(of: self))
    guard let jsonURL = bundle.url(forResource: "introspection_response", withExtension: "json") else {
      throw XCTFailure("Missing resource file!", file: #file, line: #line)
    }

    try FileManager.default.apollo.createFolderIfNeeded(at: CodegenTestHelper.outputFolderURL())
    let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: TestURL.mockPort8080.url),
                                                          outputFolderURL: CodegenTestHelper.outputFolderURL())

    try ApolloSchemaDownloader.convertFromIntrospectionJSONToSDLFile(jsonFileURL: jsonURL, configuration: configuration)
    XCTAssertTrue(FileManager.default.apollo.fileExists(at: configuration.outputURL))

    let frontend = try ApolloCodegenFrontend()
    let source = try frontend.makeSource(from: configuration.outputURL)
    let schema = try frontend.loadSchemaFromSDL(source)

    let authorType = try schema.getType(named: "Author")
    XCTAssertEqual(authorType?.name, "Author")

    let postType = try schema.getType(named: "Post")
    XCTAssertEqual(postType?.name, "Post")
  }
}

