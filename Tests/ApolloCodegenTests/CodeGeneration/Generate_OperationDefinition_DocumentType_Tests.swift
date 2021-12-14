import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
@testable import SQLite

class Generate_OperationDefinition_DocumentType_Tests: XCTestCase {

  var config: ApolloCodegenConfiguration!
  var definition: CompilationResult.OperationDefinition!

  override func setUp() {
    super.setUp()
    definition = CompilationResult.OperationDefinition.mock()
  }

  override func tearDown() {
    super.tearDown()
    config = nil
    definition = nil
  }

  func renderDocumentType() throws -> String {
    OperationDefinitionGenerator.DocumentType.render(
      operation: try XCTUnwrap(definition),
      apq: try XCTUnwrap(config.apqs)
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
    config = .mock(apqs: .disabled)

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public let document: DocumentType = .notPersisted(
      definition: .init(
      ""\"
      query NameQuery {
        name
      }
      ""\"))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesFragment_generatesWithOperationDefinitionAndFragment() throws {
    // given
    let fragment = CompilationResult.FragmentDefinition.mock()
    fragment.source =
    """
    fragment NameFragment on Person {
      name
    }
    """

    definition.source =
    """
    query NameQuery {
      ...NameFragment
    }
    """

    config = .mock(apqs: .disabled)

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public let document: DocumentType = .notPersisted(
      definition: .init(
      ""\"
      query NameQuery {
        name
      }
      ""\",
      fragments: [NameFragment.self]))
    """
    expect(actual).to(equalLineByLine(expected))
  }

  func test__generate__givenIncludesManyFragments_generatesWithOperationDefinitionAndFragment() throws {
    // given
    let fragments = [
      CompilationResult.FragmentDefinition.mock("Fragment1"),
      CompilationResult.FragmentDefinition.mock("Fragment2"),
      CompilationResult.FragmentDefinition.mock("Fragment3"),
      CompilationResult.FragmentDefinition.mock("Fragment4"),
      CompilationResult.FragmentDefinition.mock("FragmentWithLongName1234123412341234123412341234"),
    ]

    let definition = CompilationResult.OperationDefinition.mock(usingFragments: fragments)
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

    config = .mock(apqs: .disabled)

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public let document: DocumentType = .notPersisted(
      definition: .init(
      ""\"
      query NameQuery {
        name
      }
      ""\",
      fragments: [Fragment1.self, Fragment2.self, Fragment3.self, Fragment4.self, FragmentWithLongName1234123412341234123412341234.self]))
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

    config = .mock(apqs: .automaticallyPersist)

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public let document: DocumentType = .automaticallyPersisted(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5",
      definition: .init(
      ""\"
      query NameQuery {
        name
      }
      ""\"))
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

    config = .mock(apqs: .persistedOperationsOnly)

    // when
    let actual = try renderDocumentType()

    // then
    let expected =
    """
    public let document: DocumentType = .persistedOperationsOnly(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5")
    """
    expect(actual).to(equalLineByLine(expected))
  }
}
