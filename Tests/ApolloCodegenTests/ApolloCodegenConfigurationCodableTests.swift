import XCTest
import Nimble
import ApolloCodegenLib

class ApolloCodegenConfigurationCodableTests: XCTestCase {

  // MARK: - ApolloCodegenConfiguration Tests

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

  enum MockApolloCodegenConfiguration {
    static var decodedStruct: ApolloCodegenConfiguration {
      .init(
        schemaName: "SerializedSchema",
        input: .init(
          schemaPath: "/path/to/schema.graphqls",
          operationSearchPaths: [
            "/search/path/**/*.graphql"
          ]
        ),
        output: .init(
          schemaTypes: .init(
            path: "/output/path",
            moduleType: .embeddedInTarget(name: "SomeTarget")
          ),
          operations: .absolute(path: "/absolute/path"),
          testMocks: .swiftPackage(targetName: "SchemaTestMocks"),
          operationIdentifiersPath: "/operation/identifiers/path"
        ),
        options: .init(
          additionalInflectionRules: [
            .pluralization(singularRegex: "animal", replacementRegex: "animals")
          ],
          queryStringLiteralFormat: .singleLine,
          deprecatedEnumCases: .exclude,
          schemaDocumentation: .exclude,
          apqs: .persistedOperationsOnly,
          cocoapodsCompatibleImportStatements: true,
          warningsOnDeprecatedUsage: .exclude,
          conversionStrategies:.init(enumCases: .none),
          pruneGeneratedFiles: false
        ),
        experimentalFeatures: .init(
          clientControlledNullability: true,
          legacySafelistingCompatibleOperations: true
        )
      )
    }

    static var encodedJSON: String {
      """
      {
        "experimentalFeatures" : {
          "clientControlledNullability" : true,
          "legacySafelistingCompatibleOperations" : true
        },
        "input" : {
          "operationSearchPaths" : [
            "/search/path/**/*.graphql"
          ],
          "schemaSearchPaths" : [
            "/path/to/schema.graphqls"
          ]
        },
        "options" : {
          "additionalInflectionRules" : [
            {
              "pluralization" : {
                "replacementRegex" : "animals",
                "singularRegex" : "animal"
              }
            }
          ],
          "apqs" : "persistedOperationsOnly",
          "cocoapodsCompatibleImportStatements" : true,
          "conversionStrategies" : {
            "enumCases" : "none"
          },
          "deprecatedEnumCases" : "exclude",
          "pruneGeneratedFiles" : false,
          "queryStringLiteralFormat" : "singleLine",
          "schemaDocumentation" : "exclude",
          "warningsOnDeprecatedUsage" : "exclude"
        },
        "output" : {
          "operationIdentifiersPath" : "/operation/identifiers/path",
          "operations" : {
            "absolute" : {
              "path" : "/absolute/path"
            }
          },
          "schemaTypes" : {
            "moduleType" : {
              "embeddedInTarget" : {
                "name" : "SomeTarget"
              }
            },
            "path" : "/output/path"
          },
          "testMocks" : {
            "swiftPackage" : {
              "targetName" : "SchemaTestMocks"
            }
          }
        },
        "schemaName" : "SerializedSchema"
      }
      """      
    }
  }

  func test__encodeApolloCodegenConfiguration__givenAllParameters_shouldReturnJSON() throws {
    // given
    let subject = MockApolloCodegenConfiguration.decodedStruct

    // when
    let encodedJSON = try testJSONEncoder.encode(subject)
    let actual = encodedJSON.asString

    // then
    expect(actual).to(equal(MockApolloCodegenConfiguration.encodedJSON))
  }

  func test__decodeApolloCodegenConfiguration__givenAllParameters_shouldReturnStruct() throws {
    // given
    let subject = MockApolloCodegenConfiguration.encodedJSON.asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)

    // then
    expect(actual).to(equal(MockApolloCodegenConfiguration.decodedStruct))
  }

  func test__decodeApolloCodegenConfiguration__givenOnlyRequiredParameters_shouldReturnStruct() throws {
    // given
    let subject = """
      {
        "input" : {
          "operationSearchPaths" : [
            "/search/path/**/*.graphql"
          ],
          "schemaSearchPaths" : [
            "/path/to/schema.graphqls"
          ]
        },
        "output" : {
          "operations" : {
            "absolute" : {
              "path" : "/absolute/path"
            }
          },
          "schemaTypes" : {
            "moduleType" : {
              "embeddedInTarget" : {
                "name" : "SomeTarget"
              }
            },
            "path" : "/output/path"
          },
          "testMocks" : {
            "swiftPackage" : {
              "targetName" : "SchemaTestMocks"
            }
          }
        },
        "schemaName" : "SerializedSchema"
      }
      """.asData

    let expected = ApolloCodegenConfiguration.init(
      schemaName: "SerializedSchema",
      input: .init(
        schemaSearchPaths: ["/path/to/schema.graphqls"],
        operationSearchPaths: ["/search/path/**/*.graphql"]
      ),
      output: .init(
        schemaTypes: .init(
          path: "/output/path",
          moduleType: .embeddedInTarget(name: "SomeTarget")
        ),
        operations: .absolute(path: "/absolute/path"),
        testMocks: .swiftPackage(targetName: "SchemaTestMocks")
      )
    )

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)

    // then
    expect(actual).to(equal(expected))
  }

  func test__decodeApolloCodegenConfiguration__givenMissingRequiredParameters_shouldThrow() throws {
    // given
    let subject = """
      {
        "input" : {
        },
        "output" : {
        }
      }
      """.asData

    // then
    expect(try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject))
      .to(throwError())
  }

  // MARK: - QueryStringLiteralFormat Tests

  func encodedValue(_ case: ApolloCodegenConfiguration.QueryStringLiteralFormat) -> String {
    switch `case` {
    case .singleLine: return "\"singleLine\""
    case .multiline: return "\"multiline\""
    }
  }

  func test__encodeQueryStringLiteralFormat__givenSingleLine_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.QueryStringLiteralFormat.singleLine

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.singleLine)))
  }

  func test__encodeQueryStringLiteralFormat__givenMultiline_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.QueryStringLiteralFormat.multiline

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.multiline)))
  }

  func test__decodeQueryStringLiteralFormat__givenSingleLine_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.singleLine).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.QueryStringLiteralFormat.self, from: subject)

    // then
    expect(actual).to(equal(.singleLine))
  }

  func test__decodeQueryStringLiteralFormat__givenMultiline_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.multiline).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.QueryStringLiteralFormat.self, from: subject)

    // then
    expect(actual).to(equal(.multiline))
  }

  func test__decodeQueryStringLiteralFormat__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(ApolloCodegenConfiguration.QueryStringLiteralFormat.self, from: subject)
    ).to(throwError())
  }

  // MARK: - Composition Tests

  func encodedValue(_ case: ApolloCodegenConfiguration.Composition) -> String {
    switch `case` {
    case .include: return "\"include\""
    case .exclude: return "\"exclude\""
    }
  }

  func test__encodeComposition__givenInclude_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.Composition.include

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.include)))
  }

  func test__encodeComposition__givenExclude_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.Composition.exclude

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.exclude)))
  }

  func test__decodeComposition__givenInclude_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.include).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.Composition.self, from: subject)

    // then
    expect(actual).to(equal(.include))
  }

  func test__decodeComposition__givenExclude_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.exclude).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.Composition.self, from: subject)

    // then
    expect(actual).to(equal(.exclude))
  }

  func test__decodeComposition__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(ApolloCodegenConfiguration.Composition.self, from: subject)
    ).to(throwError())
  }

  // MARK: - APQConfig Tests

  func encodedValue(_ case: ApolloCodegenConfiguration.APQConfig) -> String {
    switch `case` {
    case .disabled: return "\"disabled\""
    case .automaticallyPersist: return "\"automaticallyPersist\""
    case .persistedOperationsOnly: return "\"persistedOperationsOnly\""
    }
  }

  func test__encodeAPQConfig__givenDisabled_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.APQConfig.disabled

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.disabled)))
  }

  func test__encodeAPQConfig__givenAutomaticallyPersist_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.APQConfig.automaticallyPersist

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.automaticallyPersist)))
  }

  func test__encodeAPQConfig__givenPersistedOperationsOnly_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.APQConfig.persistedOperationsOnly

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.persistedOperationsOnly)))
  }

  func test__decodeAPQConfig__givenDisabled_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.disabled).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.disabled))
  }

  func test__decodeAPQConfig__givenAutomaticallyPersist_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.automaticallyPersist).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.automaticallyPersist))
  }

  func test__decodeAPQConfig__givenPersistedOperationsOnly_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.persistedOperationsOnly).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.persistedOperationsOnly))
  }

  func test__decodeAPQConfig__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)
    ).to(throwError())
  }
}
