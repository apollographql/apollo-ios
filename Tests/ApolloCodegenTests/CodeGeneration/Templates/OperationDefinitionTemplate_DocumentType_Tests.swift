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

  func renderDocumentType() throws -> String {
    OperationDefinitionTemplate.DocumentType.render(
      try XCTUnwrap(definition),
      identifier: operationIdentifier,
      fragments: referencedFragments ?? [],
      config: ApolloCodegen.ConfigurationContext(config: config)
    ).description
  }

  func test__generate__givenMultilineFormat_generatesWithOperationDefinition_asMultiline() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """
    config = .mock(options: .init(
      queryStringLiteralFormat: .multiline,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        ""\"
        query NameQuery {
          name
        }
        ""\"
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
    config = .mock(options: .init(
      queryStringLiteralFormat: .singleLine,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        "query NameQuery {  name}"
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .multiline,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        ""\"
        query NameQuery {
          ...NameFragment
        }
        ""\",
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .singleLine,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        "query NameQuery {  ...NameFragment}",
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .singleLine,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        "query NameQuery {  ...nameFragment}",
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .multiline,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        ""\"
        query NameQuery {
          ...Fragment1
          ...Fragment2
          ...Fragment3
          ...Fragment4
          ...FragmentWithLongName1234123412341234123412341234
        }
        ""\",
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .singleLine,
      apqs: .disabled
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        "query NameQuery {  ...Fragment1  ...Fragment2  ...Fragment3  ...Fragment4  ...FragmentWithLongName1234123412341234123412341234}",
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .multiline,
      apqs: .automaticallyPersist
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5",
      definition: .init(
        ""\"
        query NameQuery {
          name
        }
        ""\"
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

    config = .mock(options: .init(
      queryStringLiteralFormat: .multiline,
      apqs: .persistedOperationsOnly
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .persistedOperationsOnly(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    )
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenCocoapodsCompatibleImportStatements_true_shouldUseCorrectNamespace() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """
    config = .mock(options: .init(
      cocoapodsCompatibleImportStatements: true
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: Apollo.DocumentType = .notPersisted(
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
    config = .mock(options: .init(
      cocoapodsCompatibleImportStatements: false
    ))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: ApolloAPI.DocumentType = .notPersisted(
    """
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}
