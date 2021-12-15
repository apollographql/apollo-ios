import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaTemplateTests: XCTestCase {

  func test__generate__givenSchemaName_generatesBoilerplate() {
    // given
    let schema = IR.Schema(name: "TestSchemaName", referencedTypes: .init([]))
    let template = SchemaTemplate(schema: schema)

    let expected = """
    import ApolloAPI

    public typealias ID = String

    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == TestSchemaName.Schema {}

    public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
    where Schema == TestSchemaName.Schema {}

    public enum Schema: SchemaConfiguration {
      public static func objectType(forTypename __typename: String) -> Object.Type? {
        switch __typename {
    """

    // when
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenWithReferencedObjects_generatesObjectTypeFunction() {
    // given
    let schema = IR.Schema(name: "ObjectSchema", referencedTypes: .init([
      GraphQLObjectType.mock("ObjA"),
      GraphQLObjectType.mock("ObjB"),
      GraphQLObjectType.mock("ObjC"),
    ]))
    let template = SchemaTemplate(schema: schema)

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
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12))
  }

  func test__generate__givenWithReferencedOtherTypes_generatesObjectTypeNotIncludingNonObjectTypesFunction() {
    // given
    let schema = IR.Schema(name: "ObjectSchema", referencedTypes: .init([
      GraphQLObjectType.mock("ObjectA"),
      GraphQLInterfaceType.mock("InterfaceB"),
      GraphQLUnionType.mock("UnionC"),
      GraphQLScalarType.mock(name: "ScalarD"),
      GraphQLEnumType.mock(name: "EnumE"),
      GraphQLInputObjectType.mock("InputObjectC"),
    ]))
    let template = SchemaTemplate(schema: schema)

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
    let actual = template.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12))
  }
}
