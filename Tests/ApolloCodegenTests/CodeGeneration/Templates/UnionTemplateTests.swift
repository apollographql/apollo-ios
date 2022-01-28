import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloAPI

class UnionTemplateTests: XCTestCase {
  let graphqlUnion = GraphQLUnionType.mock(
    "ClassroomPet",
    types: [
      GraphQLObjectType.mock("Cat"),
      GraphQLObjectType.mock("Bird"),
      GraphQLObjectType.mock("Rat"),
      GraphQLObjectType.mock("PetRock")
    ]
  )

  // MARK: Boilerplate tests

  func test_boilerplate_importsApolloAPI_generatesSwiftEnumDefinition() throws {
    // given
    let expected = """
    import ApolloAPI

    public enum ClassroomPet: UnionType, Equatable {
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_boilerplate_generatesEnumClosingBrace() throws {
    let expected = """
    }
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(String(actual.reversed())).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Enum Generation Tests

  func test_render_givenSchemaUnion_generatesEnumCases() throws {
    let expected = """
    public enum ClassroomPet: UnionType, Equatable {
      case Cat(Cat)
      case Bird(Bird)
      case Rat(Rat)
      case PetRock(PetRock)
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesEnumInitializer() throws {
    let expected = """
      public init?(_ object: Object) {
        switch object {
        case let entity as Cat: self = .Cat(entity)
        case let entity as Bird: self = .Bird(entity)
        case let entity as Rat: self = .Rat(entity)
        case let entity as PetRock: self = .PetRock(entity)
        default: return nil
        }
      }
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesObjectProperty() throws {
    let expected = """
      public var object: Object {
        switch self {
        case let .Cat(object as Object),
          let .Bird(object as Object),
          let .Rat(object as Object),
          let .PetRock(object as Object):
            return object
        }
      }
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }

  func test_render_givenSchemaUnion_generatesPossibleTypesProperty() throws {
    let expected = """
      public static let possibleTypes: [Object.Type] = [
        ModuleAPI.Cat.self,
        ModuleAPI.Bird.self,
        ModuleAPI.Rat.self,
        ModuleAPI.PetRock.self
      ]
    """

    // when
    let actual = UnionTemplate(moduleName: "ModuleAPI", graphqlUnion: graphqlUnion).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 29, ignoringExtraLines: true))
  }
}
