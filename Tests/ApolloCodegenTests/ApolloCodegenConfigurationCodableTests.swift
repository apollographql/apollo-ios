import XCTest
import Nimble
import ApolloCodegenLib

class ApolloCodegenConfigurationCodableTests: XCTestCase {

  // MARK: - ApolloCodegenConfiguration Tests

  enum MockApolloCodegenConfiguration {
    static var decoded: ApolloCodegenConfiguration {
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
            moduleType: .swiftPackageManager
          ),
          operations: .relative(subpath: "/relative/subpath"),
          testMocks: .swiftPackage(targetName: "SchemaTestMocks"),
          operationIdentifiersPath: nil
        ),
        options: .init(
          additionalInflectionRules: [
            .pluralization(singularRegex: "animal", replacementRegex: "animals")
          ],
          queryStringLiteralFormat: .multiline,
          deprecatedEnumCases: .exclude,
          schemaDocumentation: .include,
          apqs: .disabled,
          cocoapodsCompatibleImportStatements: false,
          warningsOnDeprecatedUsage: .include
        ),
        experimentalFeatures: .init(
          clientControlledNullability: true,
          legacySafelistingCompatibleOperations: true
        )
      )
    }

    static var encoded: String {
      "{\"schemaName\":\"SerializedSchema\",\"options\":{\"schemaDocumentation\":\"include\",\"warningsOnDeprecatedUsage\":\"include\",\"deprecatedEnumCases\":\"exclude\",\"apqs\":\"disabled\", \"cocoapodsCompatibleImportStatements\": false,\"additionalInflectionRules\":[{\"pluralization\":{\"singularRegex\":\"animal\",\"replacementRegex\":\"animals\"}}],\"queryStringLiteralFormat\":\"multiline\"},\"input\":{\"operationSearchPaths\":[\"\\/search\\/path\\/**\\/*.graphql\"],\"schemaSearchPaths\":[\"\\/path\\/to\\/schema.graphqls\"]},\"output\":{\"testMocks\":{\"swiftPackage\":{\"targetName\":\"SchemaTestMocks\"}},\"schemaTypes\":{\"path\":\"\\/output\\/path\",\"moduleType\":{\"swiftPackageManager\":{}}},\"operations\":{\"relative\":{\"subpath\":\"\\/relative\\/subpath\"}}},\"experimentalFeatures\":{\"clientControlledNullability\":true,\"legacySafelistingCompatibleOperations\":true}}"
    }
  }

  func test__encodeApolloCodegenConfiguration__givenAllParameters_shouldReturnJSON() throws {
    // given
    let subject = MockApolloCodegenConfiguration.decoded

    // when
    let actual = try JSONEncoder().encode(subject).asString

    // then
    expect(actual).to(equal(MockApolloCodegenConfiguration.encoded))
  }

  func test__decodeApolloCodegenConfiguration__givenAllParameters_shouldReturnStruct() throws {
    // given
    let subject = MockApolloCodegenConfiguration.encoded.asData

    // when
    let actual = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: subject)

    // then
    expect(actual).to(equal(MockApolloCodegenConfiguration.decoded))
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
    let actual = try JSONEncoder().encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.singleLine)))
  }

  func test__encodeQueryStringLiteralFormat__givenMultiline_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.QueryStringLiteralFormat.multiline

    // when
    let actual = try JSONEncoder().encode(subject).asString

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

  func test__decodeQueryStringLiteralFormat__givenUnknown_shouldReturnEnum() throws {
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
    let actual = try JSONEncoder().encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.include)))
  }

  func test__encodeComposition__givenExclude_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.Composition.exclude

    // when
    let actual = try JSONEncoder().encode(subject).asString

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

  func test__decodeComposition__givenUnknown_shouldReturnEnum() throws {
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
    let actual = try JSONEncoder().encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.disabled)))
  }

  func test__encodeAPQConfig__givenAutomaticallyPersist_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.APQConfig.automaticallyPersist

    // when
    let actual = try JSONEncoder().encode(subject).asString

    // then
    expect(actual).to(equal(encodedValue(.automaticallyPersist)))
  }

  func test__encodeAPQConfig__givenPersistedOperationsOnly_shouldReturnString() throws {
    // given
    let subject = ApolloCodegenConfiguration.APQConfig.persistedOperationsOnly

    // when
    let actual = try JSONEncoder().encode(subject).asString

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

  func test__decodeAPQConfig__givenUnknown_shouldReturnEnum() throws {
    // given
    let subject = "\"unknown\"".asData

    // then
    expect(
      try JSONDecoder().decode(ApolloCodegenConfiguration.APQConfig.self, from: subject)
    ).to(throwError())
  }
}

// MARK: - Test Helpers

fileprivate extension String {
  var asData: Data { self.data(using: .utf8)! }
}

fileprivate extension Data {
  var asString: String { String(data: self, encoding: .utf8)! }
}
