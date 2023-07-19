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
        schemaNamespace: "SerializedSchema",
        input: .init(
          schemaPath: "/path/to/schema.graphqls",
          operationSearchPaths: [
            "/search/path/**/*.graphql"
          ]
        ),
        output: .init(
          schemaTypes: .init(
            path: "/output/path",
            moduleType: .embeddedInTarget(name: "SomeTarget", accessModifier: .public)
          ),
          operations: .absolute(path: "/absolute/path", accessModifier: .internal),
          testMocks: .swiftPackage(targetName: "SchemaTestMocks"),
          operationManifest: .init(path: "/operation/identifiers/path")
        ),
        options: .init(
          additionalInflectionRules: [
            .pluralization(singularRegex: "animal", replacementRegex: "animals")
          ],
          queryStringLiteralFormat: .singleLine,
          deprecatedEnumCases: .exclude,
          schemaDocumentation: .exclude,
          operationDocumentFormat: .definition,
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
          "cocoapodsCompatibleImportStatements" : true,
          "conversionStrategies" : {
            "enumCases" : "none"
          },
          "deprecatedEnumCases" : "exclude",
          "operationDocumentFormat" : [
            "definition"
          ],
          "pruneGeneratedFiles" : false,
          "queryStringLiteralFormat" : "singleLine",
          "schemaDocumentation" : "exclude",
          "selectionSetInitializers" : {
            "localCacheMutations" : true
          },
          "warningsOnDeprecatedUsage" : "exclude"
        },
        "output" : {
          "operationManifest" : {
            "path" : "/operation/identifiers/path",
            "version" : "persistedQueries"
          },
          "operations" : {
            "absolute" : {
              "accessModifier" : "internal",
              "path" : "/absolute/path"
            }
          },
          "schemaTypes" : {
            "moduleType" : {
              "embeddedInTarget" : {
                "accessModifier" : "public",
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
        "schemaNamespace" : "SerializedSchema"
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
    expect(actual).to(equalLineByLine(MockApolloCodegenConfiguration.encodedJSON))
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
        "schemaNamespace" : "SerializedSchema"
      }
      """.asData

    let expected = ApolloCodegenConfiguration.init(
      schemaNamespace: "SerializedSchema",
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

  func test__decodeApolloCodegenConfiguration__givenOnlyRequiredParameters_withDeprecatedSchemaNameProperty_shouldReturnStruct() throws {
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
      schemaNamespace: "SerializedSchema",
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

  func test__encodeMinimalConfigurationStruct__canBeDecoded() throws {
    let config = ApolloCodegenConfiguration(
      schemaNamespace: "MinimalSchema",
      input: .init(schemaPath: "/path/to/schema.graphqls"),
      output: .init(schemaTypes: .init(
        path: "/output/path",
        moduleType: .embeddedInTarget(name: "SomeTarget")
      ))
    )

    let encodedConfig = try testJSONEncoder.encode(config)

    expect(try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: encodedConfig))
      .toNot(throwError())
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

  // MARK: - OperationDocumentFormat Tests

  func encodedValue(_ case: ApolloCodegenConfiguration.OperationDocumentFormat) -> String {
    switch `case` {
    case .definition:
      return """
    [
      "definition"
    ]
    """
    case .operationId:
      return """
    [
      "operationId"
    ]
    """
    case [.definition, .operationId]:
      return """
    [
      "definition",
      "operationId"
    ]
    """
    default:
      XCTFail("Invalid Definition")
      return ""
    }
  }

  func test__encodeOperationDocumentFormat__givenDefinition_shouldReturnStringArray() throws {
    // given
    let subject = ApolloCodegenConfiguration.OperationDocumentFormat.definition

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equalLineByLine(encodedValue(.definition)))
  }

  func test__encodeOperationDocumentFormat__givenOperationId_shouldReturnStringArray() throws {
    // given
    let subject = ApolloCodegenConfiguration.OperationDocumentFormat.operationId

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.operationId)))
  }

  func test__encodeOperationDocumentFormat__givenBoth_shouldReturnStringArray() throws {
    // given
    let subject: ApolloCodegenConfiguration.OperationDocumentFormat = [
      .definition, .operationId
    ]

    // when
    let actual = try testJSONEncoder.encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue([.definition, .operationId])))
  }

  func test__decodeOperationDocumentFormat__givenDefinition_shouldReturnOptionSet() throws {
    // given
    let subject = encodedValue(.definition).asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloCodegenConfiguration.OperationDocumentFormat.self,
      from: subject
    )

    // then
    expect(actual).to(equal(.definition))
  }

  func test__decodeOperationDocumentFormat__givenOperationId_shouldReturnOptionSet() throws {
    // given
    let subject = encodedValue(.operationId).asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloCodegenConfiguration.OperationDocumentFormat.self,
      from: subject
    )

    // then
    expect(actual).to(equal(.operationId))
  }

  func test__decodeOperationDocumentFormat__givenBoth_shouldReturnOptionSet() throws {
    // given
    let subject = encodedValue([.definition, .operationId]).asData

    // when
    let actual = try JSONDecoder().decode(
      ApolloCodegenConfiguration.OperationDocumentFormat.self,
      from: subject
    )

    // then
    expect(actual).to(equal([.definition, .operationId]))
  }

  func test__decodeOperationDocumentFormat__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(
        ApolloCodegenConfiguration.OperationDocumentFormat.self,
        from: subject
      )
    ).to(throwError())
  }

  func test__decodeOperationDocumentFormat__givenEmptyArray_shouldThrow() throws {
    // given
    let subject = "[]".asData

    // then
    expect(
      try JSONDecoder().decode(
        ApolloCodegenConfiguration.OperationDocumentFormat.self,
        from: subject
      )
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

  @available(*, deprecated, message: "Testing deprecated APQConfig")
  func test__decodeAPQConfig__givenDisabled_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.disabled).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.disabled))
  }

  @available(*, deprecated, message: "Testing deprecated APQConfig")
  func test__decodeAPQConfig__givenAutomaticallyPersist_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.automaticallyPersist).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.automaticallyPersist))
  }

  @available(*, deprecated, message: "Testing deprecated APQConfig")
  func test__decodeAPQConfig__givenPersistedOperationsOnly_shouldReturnEnum() throws {
    // given
    let subject = encodedValue(.persistedOperationsOnly).asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)

    // then
    expect(actual).to(equal(.persistedOperationsOnly))
  }

  @available(*, deprecated, message: "Testing deprecated APQConfig")
  func test__decodeAPQConfig__givenUnknown_shouldThrow() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)
    ).to(throwError())
  }

  // MARK: - Optional Tests

  func test__decodeTestMockFileOutput__givenAbsoluteWithAccessModifier_shouldReturnEnum() throws {
    // given
    let subject = """
    {
      "absolute" : {
        "path" : "x",
        "accessModifier" : "internal"
      }
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.TestMockFileOutput.self,
      from: subject
    )

    // then
    expect(decoded).to(
      equal(ApolloCodegenConfiguration.TestMockFileOutput.absolute(
        path: "x",
        accessModifier: .internal
      ))
    )
  }

  func test__decodeTestMockFileOutput__givenAbsoluteMissingAccessModifier_shouldReturnEnumWithDefaultAccessModifier() throws {
    // given
    let subject = """
    {
      "absolute" : {
        "path" : "y"
      }
    }
    """.asData

    // when
    let decoded = try JSONDecoder().decode(
      ApolloCodegenConfiguration.TestMockFileOutput.self,
      from: subject
    )

    // then
    expect(decoded).to(
      equal(ApolloCodegenConfiguration.TestMockFileOutput.absolute(
        path: "y",
        accessModifier: .public
      ))
    )
  }

  func test__decodeApolloCodegenConfiguration__withInvalidFileOutput() throws {
    // given
    let subject = """
    {
      "schemaName": "MySchema",
      "input": {
        "operationSearchPaths": ["/search/path/**/*.graphql"],
        "schemaSearchPaths": ["/path/to/schema.graphqls"]
      },
      "output": {
        "testMocks": {
          "none": {}
        },
        "schemaTypes": {
          "path": "./MySchema",
          "moduleType": {
            "swiftPackageManager": {}
          }
        },
        "operations": {
          "inSchemaModule": {}
        },
        "options": {
          "selectionSetInitializers" : {
            "operations": true,
            "namedFragments": true,
            "localCacheMutations" : true
          },
          "queryStringLiteralFormat": "multiline",
          "schemaDocumentation": "include",
          "apqs": "disabled",
          "warningsOnDeprecatedUsage": "include"
        }
      }
    }
    """.asData

    func decodeConfiguration(subject: Data) throws -> ApolloCodegenConfiguration {
      try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)
    }
    XCTAssertThrowsError(try decodeConfiguration(subject: subject)) { error in
      guard case let DecodingError.typeMismatch(type, context) = error else { return fail("Incorrect error type") }
      XCTAssertEqual("\(type)", String(describing: ApolloCodegenConfiguration.FileOutput.self))
      XCTAssertEqual(context.debugDescription, "Unrecognized key found: options")
    }
  }

  func test__decodeApolloCodegenConfiguration__withInvalidOptions() throws {
    // given
    let subject = """
    {
      "schemaName": "MySchema",
      "input": {
        "operationSearchPaths": ["/search/path/**/*.graphql"],
        "schemaSearchPaths": ["/path/to/schema.graphqls"]
      },
      "output": {
        "testMocks": {
          "none": {}
        },
        "schemaTypes": {
          "path": "./MySchema",
          "moduleType": {
            "swiftPackageManager": {}
          }
        },
        "operations": {
          "inSchemaModule": {}
        }
      },
      "options": {
        "secret_feature": "flappy_bird",
        "selectionSetInitializers" : {
          "operations": true,
          "namedFragments": true,
          "localCacheMutations" : true
        },
        "queryStringLiteralFormat": "multiline",
        "schemaDocumentation": "include",
        "apqs": "disabled",
        "warningsOnDeprecatedUsage": "include"
      }
    }
    """.asData

    func decodeConfiguration(subject: Data) throws -> ApolloCodegenConfiguration {
      try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)
    }
    XCTAssertThrowsError(try decodeConfiguration(subject: subject)) { error in
      guard case let DecodingError.typeMismatch(type, context) = error else { return fail("Incorrect error type") }
      XCTAssertEqual("\(type)", String(describing: ApolloCodegenConfiguration.OutputOptions.self))
      XCTAssertEqual(context.debugDescription, "Unrecognized key found: secret_feature")
    }
  }

  func test__decodeApolloCodegenConfiguration__withInvalidBaseConfiguration() throws {
    // given
    let subject = """
    {
      "contact_info": "42 Wallaby Way, Sydney",
      "schemaName": "MySchema",
      "input": {
        "operationSearchPaths": ["/search/path/**/*.graphql"],
        "schemaSearchPaths": ["/path/to/schema.graphqls"]
      },
      "output": {
        "testMocks": {
          "none": {}
        },
        "schemaTypes": {
          "path": "./MySchema",
          "moduleType": {
            "swiftPackageManager": {}
          }
        },
        "operations": {
          "inSchemaModule": {}
        }
      },
      "options": {
        "selectionSetInitializers" : {
          "operations": true,
          "namedFragments": true,
          "localCacheMutations" : true
        },
        "queryStringLiteralFormat": "multiline",
        "schemaDocumentation": "include",
        "apqs": "disabled",
        "warningsOnDeprecatedUsage": "include"
      }
    }
    """.asData

    func decodeConfiguration(subject: Data) throws -> ApolloCodegenConfiguration {
      try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)
    }
    XCTAssertThrowsError(try decodeConfiguration(subject: subject)) { error in
      guard case let DecodingError.typeMismatch(type, context) = error else { return fail("Incorrect error type") }
      XCTAssertEqual("\(type)", String(describing: ApolloCodegenConfiguration.self))
      XCTAssertEqual(context.debugDescription, "Unrecognized key found: contact_info")
    }
  }

  func test__decodeApolloCodegenConfiguration__withInvalidBaseConfiguration_multipleErrors() throws {
    // given
    let subject = """
    {
      "contact_info": "42 Wallaby Way, Sydney",
      "motto": "Just keep swimming",
      "schemaName": "MySchema",
      "input": {
        "operationSearchPaths": ["/search/path/**/*.graphql"],
        "schemaSearchPaths": ["/path/to/schema.graphqls"]
      },
      "output": {
        "testMocks": {
          "none": {}
        },
        "schemaTypes": {
          "path": "./MySchema",
          "moduleType": {
            "swiftPackageManager": {}
          }
        },
        "operations": {
          "inSchemaModule": {}
        }
      },
      "options": {
        "selectionSetInitializers" : {
          "operations": true,
          "namedFragments": true,
          "localCacheMutations" : true
        },
        "queryStringLiteralFormat": "multiline",
        "schemaDocumentation": "include",
        "apqs": "disabled",
        "warningsOnDeprecatedUsage": "include"
      }
    }
    """.asData

    func decodeConfiguration(subject: Data) throws -> ApolloCodegenConfiguration {
      try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)
    }
    XCTAssertThrowsError(try decodeConfiguration(subject: subject)) { error in
      guard case let DecodingError.typeMismatch(type, context) = error else { return fail("Incorrect error type") }
      XCTAssertEqual("\(type)", String(describing: ApolloCodegenConfiguration.self))
      XCTAssertEqual(context.debugDescription, "Unrecognized keys found: contact_info, motto")
    }
  }
}
