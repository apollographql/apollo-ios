import ApolloAPI
import AnimalKingdomAPI

public struct AllAnimalsQuery: GraphQLQuery {
  public let operationName: String = "AllAnimalsQuery"
  public let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "88858c283bb72f18c0049dc85b140e72a4046f469fa16a8bf4bcf01c11d8a2b7",
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
    fragments: [HeightInMeters.self, WarmBloodedDetails.self, PetDetails.self]))

  public init() {}

  public struct ResponseData: AnimalKindgomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [Animal].self),
    ] }

    public var allAnimals: [Animal] { data["allAnimals"] }

    /// `Animal`
    public struct Animal: AnimalKindgomAPI.SelectionSet, HasFragments {
      public let data: ResponseDict
      public init(data: ResponseDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("height", Height.self),
        .fragment(HeightInMeters.self),
        .typeCase(AsWarmBlooded.self),
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .typeCase(AsPet.self),
        .typeCase(AsCat.self),
        .typeCase(AsClassroomPet.self),
        .field("predators", [Predators].self),
      ] }

      public var height: Height { data["height"] }
      public var species: String { data["species"] }
      public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
      public var predators: [Predators] { data["predators"] }

      public var asCat: AsCat? { _asType() }
      public var asWarmBlooded: AsWarmBlooded? { _asType() }
      public var asPet: AsPet? { _asType() }
      public var asClassroomPet: AsClassroomPet? { _asType() }

      public struct Fragments: ResponseObject {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public var heightInMeters: HeightInMeters { _toFragment() }
      }

      /// `Animal.Height`
      public struct Height: AnimalKindgomAPI.SelectionSet {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Height.self) }
        public static var selections: [Selection] { [
          .field("feet", Int.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int { data["feet"] }
        public var inches: Int { data["inches"] }
        public var meters: Int { data["meters"] }
      }

      /// `Animal.Predators`
      public struct Predators: AnimalKindgomAPI.SelectionSet {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.Animal.self) }
        public static var selections: [Selection] { [
          .field("species", String.self),
          .typeCase(AsWarmBlooded.self),
        ] }

        public var species: String { data["species"] }

        public var asWarmBlooded: AsWarmBlooded? { _asType() }

        /// `AllAnimals.Predators.AsWarmBlooded`
        public struct AsWarmBlooded: AnimalKindgomAPI.TypeCase, HasFragments {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.WarmBlooded.self) }
          public static var selections: [Selection] { [
            .fragment(WarmBloodedDetails.self),
            .field("laysEggs", Bool.self),
          ] }

          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var height: WarmBloodedDetails.Height { data["height"] }
          public var laysEggs: Bool { data["laysEggs"] }

          public struct Fragments: ResponseObject {
            public let data: ResponseDict
            public init(data: ResponseDict) { self.data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }
        }
      }

      /// `Animal.AsCat`
      public struct AsCat: AnimalKindgomAPI.TypeCase {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Cat.self) }
        public static var selections: [Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { data["isJellicle"] }
        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predators] { data["predators"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Human? { data["owner"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }

        public struct Height: AnimalKindgomAPI.SelectionSet {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Height.self) }

          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
          public var yards: Int { data["yards"] }
          public var relativeSize: GraphQLEnum<RelativeSize> { data["relativeSize"] }
          public var centimeters: Int { data["centimeters"] }
        }
      }

      /// `Animal.AsWarmBlooded`
      public struct AsWarmBlooded: AnimalKindgomAPI.TypeCase, HasFragments {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.WarmBlooded.self) }
        public static var selections: [Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var bodyTemperature: Int { data["bodyTemperature"] }
        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predators] { data["predators"] }

        public struct Fragments: ResponseObject {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails  { _toFragment() }
        }

        public struct Height: AnimalKindgomAPI.SelectionSet {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Height.self) }

          var feet: Int { data["feet"] }
          var inches: Int { data["inches"] }
          var meters: Int { data["meters"] }
          var yards: Int { data["yards"] }
        }
      }

      /// `Animal.AsPet`
      public struct AsPet: AnimalKindgomAPI.TypeCase, HasFragments {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.Pet.self) }
        public static var selections: [Selection] { [
          .fragment(PetDetails.self),
          .typeCase(AsWarmBlooded.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predators] { data["predators"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Human? { data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asType() }

        public struct Fragments: ResponseObject {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var petDetails: PetDetails  { _toFragment() }
        }

        public struct Height: AnimalKindgomAPI.SelectionSet {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Height.self) }
          public static var selections: [Selection] { [
            .field("relativeSize", GraphQLEnum<RelativeSize>.self),
            .field("centimeters", Int.self),
          ] }

          public var relativeSize: GraphQLEnum<RelativeSize> { data["relativeSize"] }
          public var centimeters: Int { data["centimeters"] }
          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
          public var yards: Int { data["yards"] }
        }

        /// `Animal.AsPet.AsWarmBlooded`
        public struct AsWarmBlooded: AnimalKindgomAPI.TypeCase, HasFragments {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKindgomAPI.WarmBlooded.self) }

          public var height: Height { data["height"] }
          public var species: String { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predators] { data["predators"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Human? { data["owner"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }

          public struct Fragments: ResponseObject {
            public let data: ResponseDict
            public init(data: ResponseDict) { self.data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails  { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails  { _toFragment() }
          }
        }
      }

      /// `Animal.AsClassroomPet`
      public struct AsClassroomPet: AnimalKindgomAPI.TypeCase {
        public let data: ResponseDict
        public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Union(AnimalKindgomAPI.ClassroomPet.self) }
        public static var selections: [Selection] { [
          .typeCase(AsBird.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predators] { data["predators"] }

        public var asBird: AsBird? { _asType() }

        /// `Animal.AsClassroomPet.AsBird`
        public struct AsBird: AnimalKindgomAPI.SelectionSet {
          public let data: ResponseDict
          public init(data: ResponseDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Bird.self) }

          public var height: Height { data["height"] }
          public var species: String { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predators] { data["predators"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Human? { data["owner"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var wingspan: Int { data["wingspan"] }

          public struct Height: AnimalKindgomAPI.SelectionSet {
            public let data: ResponseDict
            public init(data: ResponseDict) { self.data = data }

            public static var __parentType: ParentType { .Object(AnimalKindgomAPI.Height.self) }

            public var feet: Int { data["feet"] }
            public var inches: Int { data["inches"] }
            public var meters: Int { data["meters"] }
            public var yards: Int { data["yards"] }
            public var relativeSize: GraphQLEnum<RelativeSize> { data["relativeSize"] }
            public var centimeters: Int { data["centimeters"] }
          }
        }
      }
    }
  }
}
