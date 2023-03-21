// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ClassroomPetsQuery: GraphQLQuery {
  public static let operationName: String = "ClassroomPets"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query ClassroomPets {
        classroomPets {
          __typename
          ...ClassroomPetDetails
        }
      }
      """#,
      fragments: [ClassroomPetDetails.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("classroomPets", [ClassroomPet?]?.self),
    ] }

    public var classroomPets: [ClassroomPet?]? { __data["classroomPets"] }

    public init(
      classroomPets: [ClassroomPet?]? = nil
    ) {
      let objectType = AnimalKingdomAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "classroomPets": classroomPets._fieldData
      ]))
    }

    /// ClassroomPet
    ///
    /// Parent Type: `ClassroomPet`
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
      public static var __selections: [ApolloAPI.Selection] { [
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
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
      }

      public init(
        __typename: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
        ]))
      }

      /// ClassroomPet.AsAnimal
      ///
      /// Parent Type: `Animal`
      public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }

        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          __typename: String,
          species: String
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.Animal
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "species": species
          ]))
        }
      }

      /// ClassroomPet.AsPet
      ///
      /// Parent Type: `Pet`
      public struct AsPet: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }

        public var humanName: String? { __data["humanName"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          __typename: String,
          humanName: String? = nil
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.Pet
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "humanName": humanName
          ]))
        }
      }

      /// ClassroomPet.AsWarmBlooded
      ///
      /// Parent Type: `WarmBlooded`
      public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }

        public var species: String { __data["species"] }
        public var laysEggs: Bool { __data["laysEggs"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          __typename: String,
          species: String,
          laysEggs: Bool
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.WarmBlooded,
              AnimalKingdomAPI.Interfaces.Animal
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "species": species,
              "laysEggs": laysEggs
          ]))
        }
      }

      /// ClassroomPet.AsCat
      ///
      /// Parent Type: `Cat`
      public struct AsCat: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Cat }

        public var species: String { __data["species"] }
        public var humanName: String? { __data["humanName"] }
        public var laysEggs: Bool { __data["laysEggs"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }
        public var isJellicle: Bool { __data["isJellicle"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          species: String,
          humanName: String? = nil,
          laysEggs: Bool,
          bodyTemperature: Int,
          isJellicle: Bool
        ) {
          let objectType = AnimalKingdomAPI.Objects.Cat
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "species": species,
              "humanName": humanName,
              "laysEggs": laysEggs,
              "bodyTemperature": bodyTemperature,
              "isJellicle": isJellicle
          ]))
        }
      }

      /// ClassroomPet.AsBird
      ///
      /// Parent Type: `Bird`
      public struct AsBird: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Bird }

        public var species: String { __data["species"] }
        public var humanName: String? { __data["humanName"] }
        public var laysEggs: Bool { __data["laysEggs"] }
        public var wingspan: Double { __data["wingspan"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          species: String,
          humanName: String? = nil,
          laysEggs: Bool,
          wingspan: Double
        ) {
          let objectType = AnimalKingdomAPI.Objects.Bird
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "species": species,
              "humanName": humanName,
              "laysEggs": laysEggs,
              "wingspan": wingspan
          ]))
        }
      }

      /// ClassroomPet.AsPetRock
      ///
      /// Parent Type: `PetRock`
      public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.PetRock }

        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetails: ClassroomPetDetails { _toFragment() }
        }

        public init(
          humanName: String? = nil,
          favoriteToy: String
        ) {
          let objectType = AnimalKingdomAPI.Objects.PetRock
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "humanName": humanName,
              "favoriteToy": favoriteToy
          ]))
        }
      }
    }
  }
}
