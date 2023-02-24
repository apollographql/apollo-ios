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
          "selectionSetInitializers" : {
            "localCacheMutations" : true
          },
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

  // MARK: - Selection Set Initializers Tests

  func test__encode_selectionSetInitializers__givenOperations_shouldReturnObjectString() throws {
    // given
    let subject: ApolloCodegenConfiguration.SelectionSetInitializers = [.operations]

    let expected = """
    {
      "operations" : true
    }
    """

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(expected))
  }

  func test__decode_selectionSetInitializers__givenOperations_shouldReturnOptions() throws {
    // given
    let subject = """
    {
      "operations": true
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal(.operations))
  }

  func test__decode_selectionSetInitializers__givenOperations_false_shouldReturnEmptyOptions() throws {
    // given
    let subject = """
    {
      "operations": false
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal([]))
  }

  func test__encode_selectionSetInitializers__givenNamedFragments_shouldReturnObjectString() throws {
    // given
    let subject: ApolloCodegenConfiguration.SelectionSetInitializers = [.namedFragments]

    let expected = """
    {
      "namedFragments" : true
    }
    """

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(expected))
  }

  func test__decode_selectionSetInitializers__givenNamedFragments_shouldReturnOptions() throws {
    // given
    let subject = """
    {
      "namedFragments": true
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal(.namedFragments))
  }

  func test__decode_selectionSetInitializers__givenNamedFragments_false_shouldReturnEmptyOptions() throws {
    // given
    let subject = """
    {
      "namedFragments": false
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal([]))
  }

  func test__encode_selectionSetInitializers__givenLocalCacheMutations_shouldReturnObjectString() throws {
    // given
    let subject: ApolloCodegenConfiguration.SelectionSetInitializers = [.localCacheMutations]

    let expected = """
    {
      "localCacheMutations" : true
    }
    """

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(expected))
  }

  func test__decode_selectionSetInitializers__givenLocalCacheMutations_shouldReturnOptions() throws {
    // given
    let subject = """
    {
      "localCacheMutations": true
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal(.localCacheMutations))
  }

  func test__decode_selectionSetInitializers__givenLocalCacheMutations_false_shouldReturnEmptyOptions() throws {
    // given
    let subject = """
    {
      "localCacheMutations": false
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal([]))
  }

  func test__encode_selectionSetInitializers__givenAll_shouldReturnObjectString() throws {
    // given
    let subject: ApolloCodegenConfiguration.SelectionSetInitializers = .all

    let expected = """
    {
      "localCacheMutations" : true,
      "namedFragments" : true,
      "operations" : true
    }
    """

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(expected))
  }

  func test__decode_selectionSetInitializers__givenAll_shouldReturnObjectString() throws {
    // given
    let subject = """
    {
      "operations" : true,
      "namedFragments" : true,
      "localCacheMutations" : true
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal(.all))
  }

  func test__encode_selectionSetInitializers__givenDefinitionList_shouldReturnObjectString() throws {
    // given
    let subject: ApolloCodegenConfiguration.SelectionSetInitializers = [
      .namedFragments,
      .operation(named: "Operation1"),
      .operation(named: "Operation2")
    ]

    let expected = """
    {
      "definitionsNamed" : [
        "Operation1",
        "Operation2"
      ],
      "namedFragments" : true
    }
    """

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(expected))
  }

  func test__decode_selectionSetInitializers__givenOperations_asList_shouldReturnOptions() throws {
    // given
    let subject = """
    {
      "namedFragments" : true,
      "definitionsNamed" : [
        "Operation1",
        "Operation2"
      ]
    }
    """.asData

    let expected: ApolloCodegenConfiguration.SelectionSetInitializers = [
      .namedFragments,
      .operation(named: "Operation1"),
      .operation(named: "Operation2")
    ]

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.SelectionSetInitializers.self,
      from: subject
    )

    // then
    expect(decoded).to(equal(expected))
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
