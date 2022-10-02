import ApolloAPI
import AnimalKingdomAPI

public struct ClassroomPetsQuery: GraphQLQuery {
  public let operationName: String = "ClassroomPetsQuery"
  public let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "88858c283bb72f18c0049dc85b140e72a4046f469fa16a8bf4bcf01c11d8a2b7",
    definition: .init(
    """
    query ClassroomPets {
      classroomPets {
        ...ClassroomPetDetails
      }
    }
    """,
    fragments: [ClassroomPetDetails.self]))

  public init() {}

  public struct ResponseData: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var __selections: [Selection] { [
      .field("classroomPets", [ClassroomPetDetails].self),
    ] }

    public var classroomPets: [ClassroomPetDetails] { data["classroomPets"] }
  }
}
