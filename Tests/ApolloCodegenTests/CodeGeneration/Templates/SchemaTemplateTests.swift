import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaTemplateTests: XCTestCase {
  var subject: SchemaTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(name: String = "testSchema", referencedTypes: IR.Schema.ReferencedTypes = .init([])) {
    subject = SchemaTemplate(schema: IR.Schema(name: name, referencedTypes: referencedTypes))
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate Tests

  func test__render__generatesIDTypeAlias() {
    // given
    buildSubject()

    let expected = """
    public typealias ID = String

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Protocol Tests

  func test__render__givenSchemaName_generatesSelectionSetProtocolCorrectlyCased() {
    // given
    buildSubject()

    let expected = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == TestSchema.Schema {}

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test__render__givenSchemaName_generatesTypeCaseProtocolCorrectlyCased() {
    // given
    buildSubject()

    let expected = """
    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == TestSchema.Schema {}

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Schema Tests

  func test__render__generatesEnumDefinition() {
    // given
    buildSubject()

    let expected = """
    public enum Schema: SchemaConfiguration {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__givenWithReferencedObjects_generatesObjectTypeFunctionCorrectlyCased() {
    // given
    buildSubject(
      name: "objectSchema",
      referencedTypes: .init([
        GraphQLObjectType.mock("objA"),
        GraphQLObjectType.mock("objB"),
        GraphQLObjectType.mock("objC"),
      ])
    )

    let expected = """
      public static func objectType(forTypename __typename: String) -> Object.Type? {
        switch __typename {
        case "ObjA": return ObjectSchema.ObjA.self
        case "ObjB": return ObjectSchema.ObjB.self
        case "ObjC": return ObjectSchema.ObjC.self
        default: return nil
        }
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10))
  }

  func test__render__givenWithReferencedOtherTypes_generatesObjectTypeNotIncludingNonObjectTypesFunction() {
    // given
    buildSubject(
      name: "ObjectSchema",
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ])
    )

    let expected = """
      public static func objectType(forTypename __typename: String) -> Object.Type? {
        switch __typename {
        case "ObjectA": return ObjectSchema.ObjectA.self
        default: return nil
        }
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10))
  }
}
