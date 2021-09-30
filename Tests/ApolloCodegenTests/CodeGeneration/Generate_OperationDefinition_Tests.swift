import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class Generate_OperationDefinition_Tests: XCTestCase {

  func test__generate__generatesWithOperationDefinition() {
    // given
    let definition = CompilationResult.OperationDefinition.mock()
    definition.source =
    """
    query NameQuery {
      name
    }
    """
    // APQConfig: disabled

    // when
    let actual = ""

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
    expect(actual).to(equal(expected))
  }

  func test__generate__givenIncludesFragment_generatesWithOperationDefinitionAndFragment() {
    // given
    let fragment = CompilationResult.FragmentDefinition.mock()
    fragment.source =
    """
    fragment NameFragment on Person {
      name
    }
    """
    
    let definition = CompilationResult.OperationDefinition.mock()
    definition.source =
    """
    query NameQuery {
      ...NameFragment
    }
    """

    // APQConfig: disabled

    // when
    let actual = ""

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
    expect(actual).to(equal(expected))
  }

  func test__generate__givenIncludesManyFragments_generatesWithOperationDefinitionAndFragment() {
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

    // APQConfig: disabled

    // when
    let actual = ""

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
    expect(actual).to(equal(expected))
  }

  func test__generate__givenAPQ_automaticallyPersist_generatesWithOperationDefinitionAndIdentifier() {
    // given
    let definition = CompilationResult.OperationDefinition.mock()
    definition.operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    // APQConfig: automatically persist

    // when
    let actual = ""

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
    expect(actual).to(equal(expected))
  }

  func test__generate__givenAPQ_persistedOperationsOnly_generatesWithOperationDefinitionAndIdentifier() {
    // given
    let definition = CompilationResult.OperationDefinition.mock()
    definition.operationIdentifier = "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5"
    definition.source =
    """
    query NameQuery {
      name
    }
    """

    // APQConfig: persistedOperationsOnly

    // when
    let actual = ""

    // then
    let expected =
    """
    public let document: DocumentType = .persistedOperationsOnly(
      operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5")
    """
    expect(actual).to(equal(expected))
  }
}
