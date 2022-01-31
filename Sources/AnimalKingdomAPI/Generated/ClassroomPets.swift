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
<<<<<<< HEAD
<<<<<<< HEAD
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
=======
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
=======
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
>>>>>>> bcaa9878 (Implement Fragment Template + File Generator)

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("classroomPets", [ClassroomPet].self),
    ] }

    public var classroomPets: [ClassroomPet] { data["classroomPets"] }

    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
<<<<<<< HEAD
<<<<<<< HEAD
      public let data: DataDict
      public init(data: DataDict) { self.data = data }
=======
      public let data: ResponseDict
      public init(data: ResponseDict) { self.data = data }
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
=======
      public let data: DataDict
      public init(data: DataDict) { self.data = data }
>>>>>>> bcaa9878 (Implement Fragment Template + File Generator)

      public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
      public static var selections: [Selection] { [
        .fragment(ClassroomPetDetails.self),
      ] }



      public var asAnimal: AsAnimal? { _asType() }
      public var asPet: AsPet? { _asType() }
      public var asWarmBlooded: AsWarmBlooded? { _asType() }
      public var asCat: AsCat? { _asType() }
      public var asBird: AsBird? { _asType() }
      public var asPetRock: AsPetRock? { _asType() }

    }
  }
}