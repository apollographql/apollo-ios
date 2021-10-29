import XCTest
import ApolloTestSupport
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class ApolloSchemaInternalTests: XCTestCase {
  func testFormatConversion_givenIntrospectionJSON_shouldOutputValidSDL() throws {
    let bundle = Bundle(for: type(of: self))
    guard let jsonURL = bundle.url(forResource: "introspection_response", withExtension: "json") else {
      throw XCTFailure("Missing resource file!", file: #file, line: #line)
    }

    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: CodegenTestHelper.outputFolderURL().path)
    let configuration = ApolloSchemaDownloadConfiguration(using: .introspection(endpointURL: TestURL.mockPort8080.url),
                                                          outputFolderURL: CodegenTestHelper.outputFolderURL())

    try ApolloSchemaDownloader.convertFromIntrospectionJSONToSDLFile(jsonFileURL: jsonURL, configuration: configuration)
    XCTAssertTrue(FileManager.default.apollo.doesFileExist(atPath: configuration.outputURL.path))

    let frontend = try ApolloCodegenFrontend()
    let source = try frontend.makeSource(from: configuration.outputURL)
    let schema = try frontend.loadSchemaFromSDL(source)

    let authorType = try schema.getType(named: "Author")
    XCTAssertEqual(authorType?.name, "Author")

    let postType = try schema.getType(named: "Post")
    XCTAssertEqual(postType?.name, "Post")
  }
}

