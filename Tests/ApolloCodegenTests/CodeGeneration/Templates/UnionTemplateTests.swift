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

  private func buildSubject() {
    subject = UnionTemplate(
      moduleName: "moduleAPI",
      graphqlUnion: GraphQLUnionType.mock(
        "classroomPet",
        types: [
          GraphQLObjectType.mock("cat"),
          GraphQLObjectType.mock("bird"),
          GraphQLObjectType.mock("rat"),
          GraphQLObjectType.mock("petRock")
        ]
      )
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test_render_generatesClosingBrace() throws {
    // given
    buildSubject()

    // when
    let actual = renderSubject()

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Enum Generation Tests

  func test_render_generatesSwiftEnumDefinition() throws {
    // given
    buildSubject()

    let expected = """
    public enum ClassroomPet: Union, Equatable {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesEnumCases() throws {
    // given
    buildSubject()

    let expected = """
      case Cat(Cat)
      case Bird(Bird)
      case Rat(Rat)
      case PetRock(PetRock)
      case __unknown(Object)
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesEnumInitializer() throws {
    // given
    buildSubject()

    let expected = """
      public init(_ object: Object) {
        switch object {
        case let entity as Cat: self = .Cat(entity)
        case let entity as Bird: self = .Bird(entity)
        case let entity as Rat: self = .Rat(entity)
        case let entity as PetRock: self = .PetRock(entity)
        default: self = .__unknown(object)
        }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesObjectProperty() throws {
    // given
    buildSubject()

    let expected = """
      public var object: Object {
        switch self {
        case let .Cat(object as Object),
          let .Bird(object as Object),
          let .Rat(object as Object),
          let .PetRock(object as Object),
          let .__unknown(object):
            return object
        }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 18, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesPossibleTypesProperty() throws {
    // given
    buildSubject()

    let expected = """
      public static let possibleTypes: [Object.Type] = [
        ModuleAPI.Cat.self,
        ModuleAPI.Bird.self,
        ModuleAPI.Rat.self,
        ModuleAPI.PetRock.self
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 29, ignoringExtraLines: true))
  }
}
