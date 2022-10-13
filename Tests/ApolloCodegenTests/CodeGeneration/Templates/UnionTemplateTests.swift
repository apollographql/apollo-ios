import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloAPI

class UnionTemplateTests: XCTestCase {
  var subject: UnionTemplate!

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    name: String = "ClassroomPet",
    documentation: String? = nil,
    config: ApolloCodegenConfiguration = .mock()
  ) {
    subject = UnionTemplate(
      graphqlUnion: GraphQLUnionType.mock(
        name,
        types: [
          GraphQLObjectType.mock("cat"),
          GraphQLObjectType.mock("bird"),
          GraphQLObjectType.mock("rat"),
          GraphQLObjectType.mock("petRock")
        ],
        documentation: documentation
      ),
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test_render_generatesClosingParen() throws {
    // given
    buildSubject()

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(endWith("\n)"))
  }

  // MARK: Enum Generation Tests

  func test_render_generatesSwiftEnumDefinition() throws {
    // given
    buildSubject()

    let expected = """
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }


  func test_render_givenSchemaUnionWithLowercaseName_generatesSwiftEnumDefinitionAsUppercase() throws {
    // given
    buildSubject(name: "classroomPet")

    let expected = """
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesNameProperty() throws {
    // given
    buildSubject()

    let expected = """
      name: "ClassroomPet",
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnionWithLowercaseName_generatesNamePropertyAsLowercase() throws {
    // given
    buildSubject(name: "classroomPet")

    let expected = """
      name: "classroomPet",
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_schemaTypesEmbeddedInTarget_generatesPossibleTypesPropertyWithSchameNamespace() throws {
    // given
    buildSubject()

    let expected = """
      possibleTypes: [
        TestSchema.Objects.Cat.self,
        TestSchema.Objects.Bird.self,
        TestSchema.Objects.Rat.self,
        TestSchema.Objects.PetRock.self
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_schemaTypesNotEmbeddedInTarget_generatesPossibleTypesPropertyWithoutSchemaNamespace() throws {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
      possibleTypes: [
        Objects.Cat.self,
        Objects.Bird.self,
        Objects.Rat.self,
        Objects.PetRock.self
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_swiftPackageManager_generatesSwiftEnum_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesSwiftEnum_withPublicModifier() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesSwiftEnum_noPublicModifier() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget")))

    let expected = """
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
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
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
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
    static let ClassroomPet = Union(
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}
