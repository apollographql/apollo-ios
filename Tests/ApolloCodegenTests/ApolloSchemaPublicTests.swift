import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloCodegenLib

class ApolloSchemaPublicTests: XCTestCase {
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
}

