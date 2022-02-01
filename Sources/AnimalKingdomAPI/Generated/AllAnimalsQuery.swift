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

      public var asWarmBlooded: AsWarmBlooded? { _asType() }
      public var asPet: AsPet? { _asType() }
      public var asCat: AsCat? { _asType() }
      public var asClassroomPet: AsClassroomPet? { _asType() }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var heightInMeters: HeightInMeters { _toFragment() }
      }

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

        public var asWarmBlooded: AsWarmBlooded? { _asType() }

        public struct AsWarmBlooded: AnimalKingdomAPI.TypeCase {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
          public static var selections: [Selection] { [
            .field("laysEggs", Bool.self),
            .fragment(WarmBloodedDetails.self),
          ] }

          public var laysEggs: Bool { data["laysEggs"] }
          public var species: String { data["species"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var height: WarmBloodedDetails.Height { data["height"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }
        }
      }

      public struct AsWarmBlooded: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
        public static var selections: [Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var heightInMeters: HeightInMeters { _toFragment() }
        }
      }

      public struct AsPet: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
        public static var selections: [Selection] { [
          .field("height", Height.self),
          .typeCase(AsWarmBlooded.self),
          .fragment(PetDetails.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Owner? { data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asType() }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var petDetails: PetDetails { _toFragment() }
          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
          public static var selections: [Selection] { [
            .field("relativeSize", GraphQLEnum<RelativeSize>.self),
            .field("centimeters", Int.self),
          ] }

          public var relativeSize: GraphQLEnum<RelativeSize> { data["relativeSize"] }
          public var centimeters: Int { data["centimeters"] }
          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
        }

        public struct AsWarmBlooded: AnimalKingdomAPI.TypeCase {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
          public static var selections: [Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { data["height"] }
          public var species: String { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predator] { data["predators"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Owner? { data["owner"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }
        }
      }

      public struct AsCat: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
        public static var selections: [Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { data["isJellicle"] }
        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Owner? { data["owner"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
        }
      }

      public struct AsClassroomPet: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
        public static var selections: [Selection] { [
          .typeCase(AsBird.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }

        public var asBird: AsBird? { _asType() }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        public struct AsBird: AnimalKingdomAPI.TypeCase {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
          public static var selections: [Selection] { [
            .field("wingspan", Int.self),
          ] }

          public var wingspan: Int { data["wingspan"] }
          public var height: Height { data["height"] }
          public var species: String { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predator] { data["predators"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Owner? { data["owner"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }
        }
      }
    }
  }
}
