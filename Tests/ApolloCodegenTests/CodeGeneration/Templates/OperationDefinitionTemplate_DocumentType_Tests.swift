import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class OperationDefinitionTemplate_DocumentType_Tests: XCTestCase {

  var config: ApolloCodegenConfiguration!
  var definition: CompilationResult.OperationDefinition!
  var referencedFragments: OrderedSet<IR.NamedFragment>!
  var operationIdentifier: String!

  override func setUp() {
    super.setUp()
    definition = CompilationResult.OperationDefinition.mock()
  }

  override func tearDown() {
    super.tearDown()
    config = nil
    definition = nil
    referencedFragments = nil
    operationIdentifier = nil
  }

  func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .swiftPackageManager,
    operations: ApolloCodegenConfiguration.OperationsFileOutput = .inSchemaModule,
    queryStringLiteralFormat: ApolloCodegenConfiguration.QueryStringLiteralFormat = .singleLine,
    operationDocumentFormat: ApolloCodegenConfiguration.OperationDocumentFormat = .definition,
    cocoapodsCompatibleImportStatements: Bool = false
  ) {
    config = .mock(
      output: .mock(moduleType: moduleType, operations: operations),
      options: .init(
        queryStringLiteralFormat: queryStringLiteralFormat,
        operationDocumentFormat: operationDocumentFormat,
        cocoapodsCompatibleImportStatements: cocoapodsCompatibleImportStatements
      )
    )
  }

  func renderDocumentType() throws -> String {
    let config = ApolloCodegen.ConfigurationContext(config: config)
    let mockTemplateRenderer = MockTemplateRenderer(
      target: .operationFile,
      template: "",
      config: config
    )

    return OperationDefinitionTemplate.DocumentType.render(
      try XCTUnwrap(definition),
      identifier: operationIdentifier,
      fragments: referencedFragments ?? [],
      config: config,
      accessControlRenderer: mockTemplateRenderer.accessControlModifier(for: .member)
    ).description
  }

  // MARK: Query string formatting tests

  func test__generate__givenMultilineFormat_generatesWithOperationDefinition_asMultiline() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #""\"
        query NameQuery {
          name
        }
        ""\"#
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenSingleLineFormat_generatesWithOperationDefinition_asSingleLine() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .singleLine,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NameQuery { name }"#
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenMultilineFormat_withInLineQuotes_generatesWithOperationDefinitionAsMultiline_withInlineQuotes() throws {
    // given
    definition.source =
    """
    query NameQuery($filter: String = "MyName") {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #""\"
        query NameQuery($filter: String = "MyName") {
          name
        }
        ""\"#
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenSingleLineFormat_withInLineQuotes_generatesWithOperationDefinitionAsSingleLine_withInLineQuotes() throws {
    // given
    definition.source =
    """
    query NameQuery($filter: String = "MyName") {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .singleLine,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NameQuery($filter: String = "MyName") { name }"#
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesFragment_formatMultiline_generatesWithOperationDefinitionAndFragment_asMultiline() throws {
    // given
    referencedFragments = [
      .mock("NameFragment"),
    ]

    definition.source =
    """
    query NameQuery {
      ...NameFragment
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #""\"
        query NameQuery {
          ...NameFragment
        }
        ""\"#,
        fragments: [NameFragment.self]
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesFragment_formatSingleLine_generatesWithOperationDefinitionAndFragment_asSingleLine() throws {
    // given
    referencedFragments = [
      .mock("NameFragment"),
    ]

    definition.source =
    """
    query NameQuery {
      ...NameFragment
    }
    """

    buildConfig(
      queryStringLiteralFormat: .singleLine,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NameQuery { ...NameFragment }"#,
        fragments: [NameFragment.self]
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesFragment_fragmentNameStartsWithLowercase_generatesWithOperationDefinitionAndFragment_withFirstUppercased() throws {
    // given
    referencedFragments = [
      .mock("nameFragment"),
    ]

    definition.source =
    """
    query NameQuery {
      ...nameFragment
    }
    """

    buildConfig(
      queryStringLiteralFormat: .singleLine,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NameQuery { ...nameFragment }"#,
        fragments: [NameFragment.self]
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesManyFragments_formatMultiline_generatesWithOperationDefinitionAndFragment_asMultiline() throws {
    // given
    referencedFragments = [
      .mock("Fragment1"),
      .mock("Fragment2"),
      .mock("Fragment3"),
      .mock("Fragment4"),
      .mock("FragmentWithLongName1234123412341234123412341234"),
    ]
    
    definition.source =
    """
    query NameQuery {
      ...Fragment1
      ...Fragment2
      ...Fragment3
      ...Fragment4
      ...FragmentWithLongName1234123412341234123412341234
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #""\"
        query NameQuery {
          ...Fragment1
          ...Fragment2
          ...Fragment3
          ...Fragment4
          ...FragmentWithLongName1234123412341234123412341234
        }
        ""\"#,
        fragments: [Fragment1.self, Fragment2.self, Fragment3.self, Fragment4.self, FragmentWithLongName1234123412341234123412341234.self]
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesManyFragments_formatSingleLine_generatesWithOperationDefinitionAndFragment_asSingleLine() throws {
    // given
    referencedFragments = [
      .mock("Fragment1"),
      .mock("Fragment2"),
      .mock("Fragment3"),
      .mock("Fragment4"),
      .mock("FragmentWithLongName1234123412341234123412341234"),
    ]

    definition.source =
    """
    query NameQuery {
      ...Fragment1
      ...Fragment2
      ...Fragment3
      ...Fragment4
      ...FragmentWithLongName1234123412341234123412341234
    }
    """

    buildConfig(
      queryStringLiteralFormat: .singleLine,
      operationDocumentFormat: .definition
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NameQuery { ...Fragment1 ...Fragment2 ...Fragment3 ...Fragment4 ...FragmentWithLongName1234123412341234123412341234 }"#,
        fragments: [Fragment1.self, Fragment2.self, Fragment3.self, Fragment4.self, FragmentWithLongName1234123412341234123412341234.self]
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenAPQ_automaticallyPersist_generatesWithOperationDefinitionAndIdentifier() throws {
    // given
    operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: [.definition, .operationId]
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5",
      definition: .init(
        #""\"
        query NameQuery {
          name
        }
        ""\"#
      ))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenAPQ_persistedOperationsOnly_generatesWithIdentifierOnly() throws {
    // given
    operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      queryStringLiteralFormat: .multiline,
      operationDocumentFormat: .operationId
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    )
    """
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Namespacing tests

  func test__generate__givenCocoapodsCompatibleImportStatements_true_shouldUseCorrectNamespace() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      cocoapodsCompatibleImportStatements: true
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: Apollo.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenCocoapodsCompatibleImportStatements_false_shouldUseCorrectNamespace() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      cocoapodsCompatibleImportStatements: false
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Access Level Tests

  func test__accessLevel__givenQuery_whenModuleTypeIsSwiftPackageManager_andOperationsInSchemaModule_shouldRenderWithPublicAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .inSchemaModule
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsEmbeddedInTargetWithPublicAccessModifier_andOperationsInSchemaModule_shouldRenderWithPublicAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public),
      operations: .inSchemaModule
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsEmbeddedInTargetWithInternalAccessModifier_andOperationsInSchemaModule_shouldRenderWithInternalAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      operations: .inSchemaModule
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsSwiftPackageManager_andOperationsRelativeWithPublicAccessModifier_shouldRenderWithPublicAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .relative(subpath: nil, accessModifier: .public)
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsSwiftPackageManager_andOperationsRelativeWithInternalAccessModifier_shouldRenderWithInternalAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .relative(subpath: nil, accessModifier: .internal)
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsSwiftPackageManager_andOperationsAbsoluteWithPublicAccessModifier_shouldRenderWithPublicAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .absolute(path: "", accessModifier: .public)
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__accessLevel__givenQuery_whenModuleTypeIsSwiftPackageManager_andOperationsAbsoluteWithInternalAccessModifier_shouldRenderWithInternalAccess() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    buildConfig(
      moduleType: .swiftPackageManager,
      operations: .absolute(path: "", accessModifier: .internal)
    )

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    static let operationDocument: ApolloAPI.OperationDocument = .init(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}
