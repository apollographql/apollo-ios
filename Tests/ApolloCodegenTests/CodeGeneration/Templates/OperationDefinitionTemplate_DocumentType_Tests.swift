import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class OperationDefinitionTemplate_DocumentType_Tests: XCTestCase {

  var config: ApolloCodegenConfiguration!
  var definition: CompilationResult.OperationDefinition!
  var referencedFragments: OrderedSet<IR.NamedFragment>!

  override func setUp() {
    super.setUp()
    definition = CompilationResult.OperationDefinition.mock()
  }

  override func tearDown() {
    super.tearDown()
    config = nil
    definition = nil
    referencedFragments = nil
  }

  func renderDocumentType() throws -> String {
    OperationDefinitionTemplate.DocumentType.render(
      try XCTUnwrap(definition),
      fragments: referencedFragments ?? [],
      apq: try XCTUnwrap(config.options.apqs)
    ).description
  }

  func test__generate__generatesWithOperationDefinition() throws {
    // given
    definition.source =
    """
    query NameQuery {
      name
    }
    """
    config = .mock(options: .init(apqs: .disabled))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: DocumentType = .notPersisted(
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

  func test__generate__givenIncludesFragment_generatesWithOperationDefinitionAndFragment() throws {
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

    config = .mock(options: .init(apqs: .disabled))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: DocumentType = .notPersisted(
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

  func test__generate__givenIncludesManyFragments_generatesWithOperationDefinitionAndFragment() throws {
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

    config = .mock(options: .init(apqs: .disabled))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: DocumentType = .notPersisted(
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

  func test__generate__givenAPQ_automaticallyPersist_generatesWithOperationDefinitionAndIdentifier() throws {
    // given
    definition.operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    config = .mock(options: .init(apqs: .automaticallyPersist))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: DocumentType = .automaticallyPersisted(
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

  func test__generate__givenAPQ_persistedOperationsOnly_generatesWithOperationDefinitionAndIdentifier() throws {
    // given
    definition.operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    config = .mock(options: .init(apqs: .persistedOperationsOnly))

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public static let document: DocumentType = .persistedOperationsOnly(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    )
    """
    expect(actual).to(equalLineByLine(expected))
  }
}
