import ApolloAPI

public class AllAnimalsQueryQuery: GraphQLQuery {
  public let operationName: String = "AllAnimalsQuery"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query AllAnimalsQuery {
        allAnimals {
          height {
            feet
            inches
          }
          ...HeightInMeters
          ...WarmBloodedDetails
          species
          skinCovering
          ... on Pet {
            ...PetDetails
            ...WarmBloodedDetails
            ... on Animal {
              height {
                relativeSize
                centimeters
              }
            }
          }
          ... on Cat {
            isJellicle
          }
          ... on ClassroomPet {
            ... on Bird {
              wingspan
            }
          }
          predators {
            species
            ... on WarmBlooded {
              ...WarmBloodedDetails
              laysEggs
            }
          }
        }
      }
      """,
      fragments: [HeightInMeters.self, WarmBloodedDetails.self, PetDetails.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [Animal].self),
    ] }

    public var allAnimals: [AllAnimal] { data["allAnimals"] }

    public struct AllAnimal: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("height", Height.self),
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .field("predators", [Animal].self),
        .typeCase(AsWarmBlooded.self),
        .typeCase(AsPet.self),
        .typeCase(AsCat.self),
        .typeCase(AsClassroomPet.self),
        .fragment(HeightInMeters.self),
      ] }

      public var height: Height { data["height"] }
      public var species: String { data["species"] }
      public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
      public var predators: [Predator] { data["predators"] }

      public struct Height: AnimalKingdomAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
        public static var selections: [Selection] { [
          .field("feet", Int.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int { data["feet"] }
        public var inches: Int { data["inches"] }
        public var meters: Int { data["meters"] }

      }
      public struct Predator: AnimalKingdomAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
        public static var selections: [Selection] { [
          .field("species", String.self),
          .typeCase(AsWarmBlooded.self),
        ] }

        public var species: String { data["species"] }

      }
    }
  }
}