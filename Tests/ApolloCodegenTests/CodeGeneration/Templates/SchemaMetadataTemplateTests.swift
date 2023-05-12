import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SchemaMetadataTemplateTests: XCTestCase {
  var subject: SchemaMetadataTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubject(
    referencedTypes: IR.Schema.ReferencedTypes = .init([]),
    documentation: String? = nil,
    config: ApolloCodegenConfiguration = ApolloCodegenConfiguration.mock()
  ) {
    subject = SchemaMetadataTemplate(
      schema: IR.Schema(referencedTypes: referencedTypes, documentation: documentation),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderTemplate() -> String {
    subject.template.description
  }

  private func renderDetachedTemplate() -> String? {
    subject.detachedTemplate?.description
  }

  // MARK: Typealias & Protocol Tests

  func test__render__givenModuleEmbeddedInTarget_withInternalAccessModifier_shouldGenerateIDTypealias_withInternalAccess() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "CustomTarget", accessModifier: .internal)))

    let expected = """
    typealias ID = String

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleEmbeddedInTarget_withPublicAccessModifier_shouldGenerateIDTypealias_withPublicAccess() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "CustomTarget", accessModifier: .public)))

    let expected = """
    typealias ID = String

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleSwiftPackageManager_shouldGenerateIDTypealias_withPublicAccess() {
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

  func test__render__givenModuleOther_shouldGenerateIDTypealias_withPublicAccess() {
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

  func test__render__givenModuleEmbeddedInTarget_withInternalAccessModifier_shouldGenerateDetachedProtocols_withTypealias_withCorrectCasing_withInternalAccess() {
    // given
    buildSubject(
      config: .mock(
        .embeddedInTarget(name: "CustomTarget", accessModifier: .internal),
        schemaNamespace: "aName"
      )
    )

    let expectedTemplate = """
    typealias SelectionSet = AName_SelectionSet

    typealias InlineFragment = AName_InlineFragment

    typealias MutableSelectionSet = AName_MutableSelectionSet

    typealias MutableInlineFragment = AName_MutableInlineFragment

    """

    let expectedDetached = """
    protocol AName_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.SchemaMetadata {}

    protocol AName_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}

    protocol AName_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.SchemaMetadata {}

    protocol AName_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}
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

  func test__render__givenModuleEmbeddedInTarget_withPublicAccessModifier_shouldGenerateDetachedProtocols_withTypealias_withCorrectCasing_withPublicAccess() {
    // given
    buildSubject(
      config: .mock(
        .embeddedInTarget(name: "CustomTarget", accessModifier: .public),
        schemaNamespace: "aName"
      )
    )

    let expectedTemplate = """
    typealias SelectionSet = AName_SelectionSet

    typealias InlineFragment = AName_InlineFragment

    typealias MutableSelectionSet = AName_MutableSelectionSet

    typealias MutableInlineFragment = AName_MutableInlineFragment

    """

    let expectedDetached = """
    public protocol AName_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol AName_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}

    public protocol AName_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol AName_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}
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

  func test__render__givenModuleSwiftPackageManager_shouldGenerateEmbeddedProtocols_noTypealias_withCorrectCasing_withPublicModifier() {
    // given
    buildSubject(
      config: .mock(
        .swiftPackageManager,
        schemaNamespace: "aName"
      )
    )

    let expectedTemplate = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}

    public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}
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

  func test__render__givenModuleOther_shouldGenerateEmbeddedProtocols_noTypealias_withCorrectCasing_withPublicModifier() {
    // given
    buildSubject(
      config: .mock(
        .other,
        schemaNamespace: "aName"
      )
    )

    let expectedTemplate = """
    public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}

    public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
    where Schema == AName.SchemaMetadata {}
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

  func test__render__given_cocoapodsCompatibleImportStatements_true_shouldGenerateEmbeddedProtocols_withApolloTargetName() {
    // given
    buildSubject(
      config: .mock(
        .other,
        options: .init(cocoapodsCompatibleImportStatements: true),
        schemaNamespace: "aName"
      )
    )

    let expectedTemplate = """
    public protocol SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
    where Schema == AName.SchemaMetadata {}

    public protocol MutableSelectionSet: Apollo.MutableRootSelectionSet
    where Schema == AName.SchemaMetadata {}

    public protocol MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
    where Schema == AName.SchemaMetadata {}
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

  func test__render__givenModuleEmbeddedInTarget_withInternalAccessModifier_shouldGenerateEnumDefinition_withInternalAccess() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "MockTarget", accessModifier: .internal)))

    let expected = """
    enum SchemaMetadata: ApolloAPI.SchemaMetadata {
      static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenModuleEmbeddedInTarget_withPublicAccessModifier_shouldGenerateEnumDefinition_withPublicAccess() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "MockTarget", accessModifier: .public)))

    let expected = """
    enum SchemaMetadata: ApolloAPI.SchemaMetadata {
      public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenModuleSwiftPackageManager_shouldGenerateEnumDefinition_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
      public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render__givenModuleOther_shouldGenerateEnumDefinition_withPublicModifier() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
      public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render__givenCocoapodsCompatibleImportStatements_true_shouldGenerateEnumDefinition_withApolloTargetName() {
    // given
    buildSubject(config: .mock(options: .init(cocoapodsCompatibleImportStatements: true)))

    let expected = """
    enum SchemaMetadata: Apollo.SchemaMetadata {
      static let configuration: Apollo.SchemaConfiguration.Type = SchemaConfiguration.self
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenWithReferencedObjects_generatesObjectTypeFunctionCorrectlyCased() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("objA"),
        GraphQLObjectType.mock("objB"),
        GraphQLObjectType.mock("objC"),
      ]),
      config: .mock(schemaNamespace: "objectSchema")
    )

    let expected = """
      static func objectType(forTypename typename: String) -> Object? {
        switch typename {
        case "objA": return ObjectSchema.Objects.ObjA
        case "objB": return ObjectSchema.Objects.ObjB
        case "objC": return ObjectSchema.Objects.ObjC
        default: return nil
        }
      }
    }
    
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render__givenWithReferencedOtherTypes_generatesObjectTypeNotIncludingNonObjectTypesFunction() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ]),
      config: .mock(schemaNamespace: "ObjectSchema")
    )

    let expected = """
      static func objectType(forTypename typename: String) -> Object? {
        switch typename {
        case "ObjectA": return ObjectSchema.Objects.ObjectA
        default: return nil
        }
      }
    }
    
    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render__givenModuleEmbeddedInTarget_withInternalAccessModifier_rendersTypeNamespaceEnums_withInternalAccess() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ]),
      config: .mock(
        .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
        schemaNamespace: "ObjectSchema"
      )
    )

    let expected = """
    enum Objects {}
    enum Interfaces {}
    enum Unions {}

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 22))
  }

  func test__render__givenModuleEmbeddedInTarget_withPublicAccessModifier_rendersTypeNamespaceEnums_withPublicAccess() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ]),
      config: .mock(
        .embeddedInTarget(name: "TestTarget", accessModifier: .public),
        schemaNamespace: "ObjectSchema"
      )
    )

    let expected = """
    enum Objects {}
    enum Interfaces {}
    enum Unions {}

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 22))
  }

  func test__render__givenModuleSwiftPackageManager_rendersTypeNamespaceEnums_withPublicAccess() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ]),
      config: .mock(
        .swiftPackageManager,
        schemaNamespace: "ObjectSchema"
      )
    )

    let expected = """
    public enum Objects {}
    public enum Interfaces {}
    public enum Unions {}

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 26))
  }

  func test__render__givenModuleOther_rendersTypeNamespaceEnums_withPublicAccess() {
    // given
    buildSubject(
      referencedTypes: .init([
        GraphQLObjectType.mock("ObjectA"),
        GraphQLInterfaceType.mock("InterfaceB"),
        GraphQLUnionType.mock("UnionC"),
        GraphQLScalarType.mock(name: "ScalarD"),
        GraphQLEnumType.mock(name: "EnumE"),
        GraphQLInputObjectType.mock("InputObjectC"),
      ]),
      config: .mock(
        .other,
        schemaNamespace: "ObjectSchema"
      )
    )

    let expected = """
    public enum Objects {}
    public enum Interfaces {}
    public enum Unions {}

    """

    // when
    let actual = renderTemplate()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 26))
  }

  // MARK: Documentation Tests

  func test__render__givenSchemaDocumentation_include_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      config: .mock(options: .init(schemaDocumentation: .include))
    )

    let expected = """
    /// \(documentation)
    enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    """

    // when
    let rendered = renderTemplate()

    // then
    expect(rendered).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      documentation: documentation,
      config: .mock(options: .init(schemaDocumentation: .exclude))
    )

    let expected = """
    enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    """

    // when
    let rendered = renderTemplate()

    // then
    expect(rendered).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

}
