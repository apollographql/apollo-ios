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

  private func buildSubject(name: String = "TestSchema", referencedTypes: IR.Schema.ReferencedTypes = .init([])) {
    subject = SchemaTemplate(schema: IR.Schema(name: name, referencedTypes: referencedTypes))
  }

  // MARK: Boilerplate Tests

  func test__render__generatesHeaderComment() {
    // given
    buildSubject()

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__generatesImportStatement() {
    // given
    buildSubject()

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test__render__generatesIDTypeAlias() {
    // given
    buildSubject()

    let expected = """
    public typealias ID = String

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Protocol Tests



  func test__render__givenSchemaName_generatesSelectionSetProtocol() {
    // given
    buildSubject()

    let expected = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == TestSchema.Schema {}

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__givenSchemaName_generatesTypeCaseProtocol() {
    // given
    buildSubject()

    let expected = """
    public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
    where Schema == TestSchema.Schema {}

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: Schema Tests

  func test__render__generatesEnumDefinition() {
    // given
    buildSubject()

    let expected = """
    public enum Schema: SchemaConfiguration {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render__givenWithReferencedObjects_generatesObjectTypeFunction() {
    // given
    buildSubject(
      name: "ObjectSchema",
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjA"),
        GraphQLObjectType.mock("ObjB"),
        GraphQLObjectType.mock("ObjC"),
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15))
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15))
  }
}
