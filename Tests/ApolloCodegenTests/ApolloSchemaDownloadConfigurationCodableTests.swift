import XCTest
import Nimble
import ApolloCodegenLib

class ApolloSchemaDownloadConfigurationCodableTests: XCTestCase {

  var testJSONEncoder: JSONEncoder!

  override func setUp() {
    super.setUp()

    testJSONEncoder = JSONEncoder()
    testJSONEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
  }

  override func tearDown() {
    testJSONEncoder = nil

    super.tearDown()
  }

  // MARK: - ApolloSchemaDownloadConfiguration Tests

  func test__encodeApolloSchemaDownloadConfiguration__givenAllParameters_shouldReturnJSON_withHTTPHeadersAsArrayOfDictionaries() throws {
    // given
    let subject = ApolloSchemaDownloadConfiguration(
      using: .introspection(
        endpointURL: URL(string: "http://server.com")!,
        httpMethod: .POST,
        outputFormat: .SDL,
        includeDeprecatedInputValues: true),
      timeout: 120,
      headers: [
        .init(key: "Accept-Encoding", value: "gzip"),
        .init(key: "Authorization", value: "Bearer <token>")
      ],
      outputPath: "ServerSchema.graphqls"
    )

    // when
    let encodedJSON = try testJSONEncoder.encode(subject)
    let actual = encodedJSON.asString

    let expected = """
      {
        "downloadMethod" : {
          "introspection" : {
            "endpointURL" : "http://server.com",
            "httpMethod" : {
              "POST" : {

              }
            },
            "includeDeprecatedInputValues" : true,
            "outputFormat" : "SDL"
          }
        },
        "downloadTimeout" : 120,
        "headers" : [
          {
            "key" : "Accept-Encoding",
            "value" : "gzip"
          },
          {
            "key" : "Authorization",
            "value" : "Bearer <token>"
          }
        ],
        "outputPath" : "ServerSchema.graphqls"
      }
      """

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloSchemaDownloadConfiguration__givenAllParameters_withHTTPHeadersAsArrayOfDictionaries_shouldReturnStruct() throws {
    // given
    let subject = """
      {
        "downloadMethod" : {
          "introspection" : {
            "endpointURL" : "http://server.com",
            "httpMethod" : {
              "POST" : {

              }
            },
            "includeDeprecatedInputValues" : true,
            "outputFormat" : "SDL"
          }
        },
        "downloadTimeout" : 120,
        "headers" : [
          {
            "key" : "Accept-Encoding",
            "value" : "gzip"
          },
          {
            "key" : "Authorization",
            "value" : "Bearer <token>"
          }
        ],
        "outputPath" : "ServerSchema.graphqls"
      }
      """

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.self,
      from: subject.asData
    )

    let expected = ApolloSchemaDownloadConfiguration(
      using: .introspection(
        endpointURL: URL(string: "http://server.com")!,
        httpMethod: .POST,
        outputFormat: .SDL,
        includeDeprecatedInputValues: true),
      timeout: 120,
      headers: [
        .init(key: "Accept-Encoding", value: "gzip"),
        .init(key: "Authorization", value: "Bearer <token>")
      ],
      outputPath: "ServerSchema.graphqls"
    )

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloSchemaDownloadConfiguration__givenAllParameters_withHTTPHeadersAsDictionary_shouldReturnStruct() throws {
    // given
    let subject = """
      {
        "downloadMethod" : {
          "introspection" : {
            "endpointURL" : "http://server.com",
            "httpMethod" : {
              "POST" : {

              }
            },
            "includeDeprecatedInputValues" : true,
            "outputFormat" : "SDL"
          }
        },
        "downloadTimeout" : 120,
        "headers" : {
          "Accept-Encoding" : "gzip",
          "Authorization" : "Bearer <token>"
        },
        "outputPath" : "ServerSchema.graphqls"
      }
      """

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.self,
      from: subject.asData
    )

    let expected = ApolloSchemaDownloadConfiguration(
      using: .introspection(
        endpointURL: URL(string: "http://server.com")!,
        httpMethod: .POST,
        outputFormat: .SDL,
        includeDeprecatedInputValues: true),
      timeout: 120,
      headers: [
        .init(key: "Accept-Encoding", value: "gzip"),
        .init(key: "Authorization", value: "Bearer <token>")
      ],
      outputPath: "ServerSchema.graphqls"
    )

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloSchemaDownloadConfiguration__givenOnlyRequiredParameters_shouldReturnStruct() throws {
    // given
    let subject = """
      {
        "downloadMethod" : {
          "introspection" : {
            "endpointURL" : "http://server.com",
            "httpMethod" : {
              "POST" : {

              }
            },
            "includeDeprecatedInputValues" : true,
            "outputFormat" : "SDL"
          }
        },
        "outputPath" : "ServerSchema.graphqls"
      }
      """.asData

    let expected = ApolloSchemaDownloadConfiguration(
      using: .introspection(
        endpointURL: URL(string: "http://server.com")!,
        httpMethod: .POST,
        outputFormat: .SDL,
        includeDeprecatedInputValues: true),
      outputPath: "ServerSchema.graphqls")

    // when
    let actual = try JSONDecoder().decode(ApolloSchemaDownloadConfiguration.self, from: subject)

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloSchemaDownloadConfiguration__givenMissingRequiredParameters_shouldThrow() throws {
    // given
    let subject = """
      {}
      """.asData

    // then
    expect(try JSONDecoder().decode(ApolloSchemaDownloadConfiguration.self, from: subject))
      .to(throwError())
  }

  // MARK: - ApolloRegistrySettings Tests

  enum MockApolloRegistrySettings {
    static var decodedStruct: ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings {
      .init(apiKey: "ABC123", graphID: "DEF456", variant: "final")
    }

    static var encodedJSON: String {
      """
      {
        "apiKey" : "ABC123",
        "graphID" : "DEF456",
        "variant" : "final"
      }
      """
    }
  }

  func test__encodeApolloRegistrySettings__givenAllParameters_shouldReturnJSON() throws {
    // given
    let subject = MockApolloRegistrySettings.decodedStruct

    // when
    let encodedJSON = try testJSONEncoder.encode(subject)
    let actual = encodedJSON.asString

    // then
    expect(actual).to(equal(MockApolloRegistrySettings.encodedJSON))
  }

  func test__decodeApolloRegistrySettings__givenAllParameters_shouldReturnStruct() throws {
    // given
    let subject = MockApolloRegistrySettings.encodedJSON.asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings.self,
      from: subject
    )

    // then
    expect(actual).to(equal(MockApolloRegistrySettings.decodedStruct))
  }

  func test__decodeApolloRegistrySettings__givenOnlyRequiredParameters_shouldReturnStruct() throws {
    // given
    let subject = """
      {
        "apiKey" : "EGWRB",
        "graphID" : "YUNRT"
      }
      """.asData

    let expected = ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings(
      apiKey: "EGWRB",
      graphID: "YUNRT"
    )

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings.self,
      from: subject
    )

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloRegistrySettings__givenMissingRequiredParameters_shouldThrow() throws {
    // given
    let subject = """
      {}
      """.asData

    // then
    expect(try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings.self,
      from: subject
    )).to(throwError())
  }

  // MARK: - OutputFormat Tests

  func encodedValue(_ case: ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat) -> String {
    switch `case` {
    case .SDL: return "\"SDL\""
    case .JSON: return "\"JSON\""
    }
  }

  func test__encodeOutputFormat__givenSDL_shouldReturnString() throws {
    // given
    let subject = ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat.SDL

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.SDL)))
  }

  func test__encodeOutputFormat__givenJSON_shouldReturnString() throws {
    // given
    let subject = ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat.JSON

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.JSON)))
  }

  func test__decodeOutputFormat__givenSDL_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.SDL).asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat.self,
      from: subject
    )

    // then
    expect(actual).to(equal(.SDL))
  }

  func test__decodeOutputFormat__givenJSON_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.JSON).asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat.self,
      from: subject
    )

    // then
    expect(actual).to(equal(.JSON))
  }

  func test__decodeOutputFormat__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(
        ApolloSchemaDownloadConfiguration.DownloadMethod.OutputFormat.self,
        from: subject
      )
    ).to(throwError())
  }
}
