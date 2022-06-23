import XCTest
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class ApolloSchemaInternalTests: XCTestCase {
  func testFormatConversion_givenIntrospectionJSON_shouldOutputValidSDL() throws {
    let bundle = Bundle(for: type(of: self))
    guard let jsonURL = bundle.url(forResource: "introspection_response", withExtension: "json") else {
      throw XCTFailure("Missing resource file!", file: #file, line: #line)
    }

    try FileManager.default.apollo.createDirectoryIfNeeded(atPath: CodegenTestHelper.outputFolderURL().path)
    let configuration = ApolloSchemaDownloadConfiguration(
      using: .introspection(endpointURL: TestURL.mockPort8080.url),
      outputPath: CodegenTestHelper.schemaOutputURL().path
    )

    try ApolloSchemaDownloader.convertFromIntrospectionJSONToSDLFile(jsonFileURL: jsonURL, configuration: configuration)
    XCTAssertTrue(FileManager.default.apollo.doesFileExist(atPath: configuration.outputPath))

    let frontend = try GraphQLJSFrontend()
    let source = try frontend.makeSource(from: URL(fileURLWithPath: configuration.outputPath))
    let schema = try frontend.loadSchema(from: [source])

    let authorType = try schema.getType(named: "Author")
    XCTAssertEqual(authorType?.name, "Author")

    let postType = try schema.getType(named: "Post")
    XCTAssertEqual(postType?.name, "Post")
  }

  func testRequest_givenIntrospectionGETDownload_shouldOutputGETRequest() throws {
    let url = ApolloInternalTestHelpers.TestURL.mockServer.url
    let queryParameterName = "customParam"
    let headers: [ApolloSchemaDownloadConfiguration.HTTPHeader] = [
      .init(key: "key1", value: "value1"),
      .init(key: "key2", value: "value2")
    ]

    let request = try ApolloSchemaDownloader.introspectionRequest(from: url,
                                                                  httpMethod: .GET(queryParameterName: queryParameterName),
                                                                  headers: headers)

    XCTAssertEqual(request.httpMethod, "GET")
    XCTAssertNil(request.httpBody)

    XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    for header in headers {
      XCTAssertEqual(request.allHTTPHeaderFields?[header.key], header.value)
    }

    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    components?.queryItems = [URLQueryItem(name: queryParameterName, value: ApolloSchemaDownloader.IntrospectionQuery)]

    XCTAssertNotNil(components?.url)
    XCTAssertEqual(request.url, components?.url)
  }

  func testRequest_givenIntrospectionPOSTDownload_shouldOutputPOSTRequest() throws {
    let url = ApolloInternalTestHelpers.TestURL.mockServer.url
    let headers: [ApolloSchemaDownloadConfiguration.HTTPHeader] = [
      .init(key: "key1", value: "value1"),
      .init(key: "key2", value: "value2")
    ]

    let request = try ApolloSchemaDownloader.introspectionRequest(from: url, httpMethod: .POST, headers: headers)

    XCTAssertEqual(request.httpMethod, "POST")
    XCTAssertEqual(request.url, url)

    XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    for header in headers {
      XCTAssertEqual(request.allHTTPHeaderFields?[header.key], header.value)
    }

    let requestBody = UntypedGraphQLRequestBodyCreator.requestBody(for: ApolloSchemaDownloader.IntrospectionQuery,
                                                                   variables: nil,
                                                                   operationName: "IntrospectionQuery")
    let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [.sortedKeys])

    XCTAssertEqual(request.httpBody, bodyData)
  }

  func testRequest_givenRegistryDownload_shouldOutputPOSTRequest() throws {
    let apiKey = "custom-api-key"
    let graphID = "graph-id"
    let variant = "a-variant"
    let headers: [ApolloSchemaDownloadConfiguration.HTTPHeader] = [
      .init(key: "key1", value: "value1"),
      .init(key: "key2", value: "value2"),
    ]

    let request = try ApolloSchemaDownloader.registryRequest(with: .init(apiKey: apiKey,
                                                                         graphID: graphID,
                                                                         variant: variant),
                                                             headers: headers)

    XCTAssertEqual(request.httpMethod, "POST")
    XCTAssertEqual(request.url, ApolloSchemaDownloader.RegistryEndpoint)

    XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    XCTAssertEqual(request.allHTTPHeaderFields?["x-api-key"], apiKey)
    for header in headers {
      XCTAssertEqual(request.allHTTPHeaderFields?[header.key], header.value)
    }

    let variables: [String: String] = [
      "graphID": graphID,
      "variant": variant
    ]
    let requestBody = UntypedGraphQLRequestBodyCreator.requestBody(for: ApolloSchemaDownloader.RegistryDownloadQuery,
                                                                   variables: variables,
                                                                   operationName: "DownloadSchema")
    let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [.sortedKeys])

    XCTAssertEqual(request.httpBody, bodyData)
  }
}
