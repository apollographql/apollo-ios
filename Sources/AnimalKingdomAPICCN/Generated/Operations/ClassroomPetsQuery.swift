// @generated
// This file was automatically generated and should not be edited.

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

    /// ClassroomPet
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

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

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
      }

      /// ClassroomPet.AsAnimal
      public struct AsAnimal: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }

        public var species: String { data["species"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsPet
      public struct AsPet: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }

        public var humanName: String? { data["humanName"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsWarmBlooded
      public struct AsWarmBlooded: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }

        public var species: String { data["species"] }
        public var laysEggs: Bool { data["laysEggs"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsCat
      public struct AsCat: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }

        public var species: String { data["species"] }
        public var humanName: String? { data["humanName"] }
        public var laysEggs: Bool { data["laysEggs"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }
        public var isJellicle: Bool { data["isJellicle"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsBird
      public struct AsBird: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }

        public var species: String { data["species"] }
        public var humanName: String? { data["humanName"] }
        public var laysEggs: Bool { data["laysEggs"] }
        public var wingspan: Float { data["wingspan"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsPetRock
      public struct AsPetRock: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.PetRock.self) }

        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }
    }
  }
}