import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class FragmentTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var fragment: IR.NamedFragment!
  var config: ApolloCodegenConfiguration!
  var subject: FragmentTemplate!

  override func setUp() {
    super.setUp()
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    fragment TestFragment on Query {
      allAnimals {
        species
      }
    }
    """

    config = .mock()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    fragment = nil
    config = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubjectAndFragment(named fragmentName: String = "TestFragment") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let fragmentDefinition = try XCTUnwrap(ir.compilationResult[fragment: fragmentName])
    fragment = ir.build(fragment: fragmentDefinition)
    subject = FragmentTemplate(
      fragment: fragment,
      schema: ir.schema,
      config: config.output
    )
  }

  // MARK: - Boilerplate Tests

  func test__render__generatesHeaderComment() throws {
    // given
    config = .mock(output: .mock(
      moduleType: .none,
      schemaName: "TestModuleName",
      operations: .inSchemaModule
    ))

    let expected =
    """
    // @generated
    // This file was automatically generated and should not be edited.
    
    """

    // when
    try buildSubjectAndFragment()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: - Fragment Definition

  func test__render__givenFragment_generatesFragmentDeclarationDefinitionAndBoilerplate() throws {
    // given
    let expected =
    """
    public struct TestFragment: TestSchema.SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
        fragment TestFragment on Query {
          allAnimals {
            species
          }
        }
        ""\" }

      public let data: DataDict
      public init(data: DataDict) { self.data = data }
    """

    // when
    try buildSubjectAndFragment()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  func test__render__givenFragmentWithUnderscoreInName_rendersDeclarationWithName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    fragment Test_Fragment on Animal {
      species
    }
    """

    let expected = """
    public struct Test_Fragment: TestSchema.SelectionSet, Fragment {
    """

    // when
    try buildSubjectAndFragment(named: "Test_Fragment")
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Object_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    fragment TestFragment on Animal {
      species
    }
    """

    let expected = """
      public static var __parentType: ParentType { .Object(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndFragment()
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Interface_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    fragment TestFragment on Animal {
      species
    }
    """

    let expected = """
      public static var __parentType: ParentType { .Interface(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndFragment()
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Union_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
    }

    union Animal = Dog
    """

    document = """
    fragment TestFragment on Animal {
      ... on Dog {
        species
      }
    }
    """

    let expected = """
      public static var __parentType: ParentType { .Union(TestSchema.Animal.self) }
    """

    // when
    try buildSubjectAndFragment()
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 18, ignoringExtraLines: true))
  }

}
