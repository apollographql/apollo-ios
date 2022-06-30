// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class ClassroomPetsQuery: GraphQLQuery {
  public static let operationName: String = "ClassroomPets"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query ClassroomPets {
        classroomPets {
          __typename
          ...ClassroomPetDetails
        }
      }
      """,
      fragments: [ClassroomPetDetails.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("classroomPets", [ClassroomPet?]?.self),
    ] }

    public var classroomPets: [ClassroomPet?]? { __data["classroomPets"] }

    /// ClassroomPet
    ///
    /// Parent Type: `ClassroomPet`
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
      public static var selections: [Selection] { [
        .fragment(ClassroomPetDetails.self),
      ] }

      public var asAnimal: AsAnimal? { _asInlineFragment() }
      public var asPet: AsPet? { _asInlineFragment() }
      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }
      public var asCat: AsCat? { _asInlineFragment() }
      public var asBird: AsBird? { _asInlineFragment() }
      public var asPetRock: AsPetRock? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
      }

      /// ClassroomPet.AsAnimal
      ///
      /// Parent Type: `Animal`
      public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }

        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsPet
      ///
      /// Parent Type: `Pet`
      public struct AsPet: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }

        public var humanName: String? { __data["humanName"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsWarmBlooded
      ///
      /// Parent Type: `WarmBlooded`
      public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }

        public var species: String { __data["species"] }
        public var laysEggs: Bool { __data["laysEggs"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsCat
      ///
      /// Parent Type: `Cat`
      public struct AsCat: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }

        public var species: String { __data["species"] }
        public var humanName: String? { __data["humanName"] }
        public var laysEggs: Bool { __data["laysEggs"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }
        public var isJellicle: Bool { __data["isJellicle"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsBird
      ///
      /// Parent Type: `Bird`
      public struct AsBird: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }

        public var species: String { __data["species"] }
        public var humanName: String? { __data["humanName"] }
        public var laysEggs: Bool { __data["laysEggs"] }
        public var wingspan: Double { __data["wingspan"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }

      /// ClassroomPet.AsPetRock
      ///
      /// Parent Type: `PetRock`
      public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.PetRock.self) }

        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }
      }
    }
  }
}
