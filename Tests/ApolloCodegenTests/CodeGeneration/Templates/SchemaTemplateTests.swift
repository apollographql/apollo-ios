import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

class SchemaTemplateTests: XCTestCase {
  var subject: SchemaTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    name: String = "testSchema",
    referencedTypes: IR.Schema.ReferencedTypes = .init([]),
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock()
  ) {
    subject = SchemaTemplate(
      schema: IR.Schema(name: name, referencedTypes: referencedTypes),
      config: ReferenceWrapped(value: config)
    )
  }

  private func renderTemplate() -> String {
    subject.template.description
  }

  private func renderDetachedTemplate() -> String? {
    subject.detachedTemplate?.description
  }

  // MARK: Typealias & Protocol Tests

  func test__render__givenModuleEmbeddedInTarget_shouldGenerateIDTypealias() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "CustomTarget")))

    let expected = """
    public typealias ID = String

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleSwiftPackageManager_shouldGenerateIDTypealias() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public typealias ID = String

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleOther_shouldGenerateIDTypealias() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public typealias ID = String

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleEmbeddedInTarget_shouldGenerateDetachedProtocols_withTypealias_withCorrectCasing() {
    // given
    buildSubject(
      name: "aName",
      config: .mock(.embeddedInTarget(name: "CustomTarget"))
    )

    let expectedTemplate = """
    public typealias SelectionSet = AName_SelectionSet

    public typealias InlineFragment = AName_InlineFragment

    """

    let expectedDetached = """
    public protocol AName_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.Schema {}

    public protocol AName_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}

    public protocol AName_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.Schema {}

    public protocol AName_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}
    """

    // when
    let actualTemplate = renderTemplate()
    let actualDetached = renderDetachedTemplate()

    // then
    expect(actualTemplate)
      .to(equalLineByLine(expectedTemplate, atLine: 3, ignoringExtraLines: true))
    expect(actualDetached)
      .to(equalLineByLine(expectedDetached))
  }

  func test__render__givenModuleSwiftPackageManager_shouldGenerateEmbeddedProtocols_noTypealias_withCorrectCasing() {
    // given
    buildSubject(
      name: "aName",
      config: .mock(.swiftPackageManager)
    )

    let expectedTemplate = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.Schema {}

    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}

    public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.Schema {}

    public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}
    """

    // when
    let actualTemplate = renderTemplate()
    let actualDetached = renderDetachedTemplate()

    // then
    expect(actualTemplate)
      .to(equalLineByLine(expectedTemplate, atLine: 3, ignoringExtraLines: true))
    expect(actualDetached)
      .to(beNil())
  }

  func test__render__givenModuleOther_shouldGenerateEmbeddedProtocols_noTypealias_withCorrectCasing() {
    // given
    buildSubject(
      name: "aName",
      config: .mock(.other)
    )

    let expectedTemplate = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.Schema {}

    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}

    public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.Schema {}

    public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.Schema {}
    """

    // when
    let actualTemplate = renderTemplate()
    let actualDetached = renderDetachedTemplate()

    // then
    expect(actualTemplate)
      .to(equalLineByLine(expectedTemplate, atLine: 3, ignoringExtraLines: true))
    expect(actualDetached)
      .to(beNil())
  }

  // MARK: Schema Tests

  func test__render__generatesEnumDefinition() {
    // given
    buildSubject()

    let expected = """
    public enum Schema: SchemaConfiguration {
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
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
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8))
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
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8))
  }
}
