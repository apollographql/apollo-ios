import ApolloAPI

public class ClassroomPetsQuery: GraphQLQuery {
  public let operationName: String = "ClassroomPets"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query ClassroomPets {
        classroomPets {
          ...ClassroomPetDetails
        }
      }
      """,
      fragments: [ClassroomPetDetails.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("classroomPets", [ClassroomPet].self),
    ] }

    public var classroomPets: [ClassroomPet] { data["classroomPets"] }

    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
      public static var selections: [Selection] { [
        .fragment(ClassroomPetDetails.self),
      ] }


    }
  }
}