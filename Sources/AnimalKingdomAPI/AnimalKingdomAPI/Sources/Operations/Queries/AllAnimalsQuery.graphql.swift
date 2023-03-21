// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllAnimalsQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsQuery"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query AllAnimalsQuery {
        allAnimals {
          __typename
          height {
            __typename
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
                __typename
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
          ... on Dog {
            favoriteToy
            birthdate
          }
          predators {
            __typename
            species
            ... on WarmBlooded {
              predators {
                __typename
                species
              }
              ...WarmBloodedDetails
              laysEggs
            }
          }
        }
      }
      """#,
      fragments: [HeightInMeters.self, WarmBloodedDetails.self, PetDetails.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    public init(
      allAnimals: [AllAnimal]
    ) {
      let objectType = AnimalKingdomAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "allAnimals": allAnimals._fieldData
      ]))
    }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("height", Height.self),
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<AnimalKingdomAPI.SkinCovering>?.self),
        .field("predators", [Predator].self),
        .inlineFragment(AsWarmBlooded.self),
        .inlineFragment(AsPet.self),
        .inlineFragment(AsCat.self),
        .inlineFragment(AsClassroomPet.self),
        .inlineFragment(AsDog.self),
        .fragment(HeightInMeters.self),
      ] }

      public var height: Height { __data["height"] }
      public var species: String { __data["species"] }
      public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
      public var predators: [Predator] { __data["predators"] }

      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }
      public var asPet: AsPet? { _asInlineFragment() }
      public var asCat: AsCat? { _asInlineFragment() }
      public var asClassroomPet: AsClassroomPet? { _asInlineFragment() }
      public var asDog: AsDog? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public var heightInMeters: HeightInMeters { _toFragment() }
      }

      public init(
        __typename: String,
        height: Height,
        species: String,
        skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
        predators: [Predator]
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
            "height": height._fieldData,
            "species": species,
            "skinCovering": skinCovering,
            "predators": predators._fieldData
        ]))
      }

      /// AllAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: AnimalKingdomAPI.SelectionSet {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("feet", Int.self),
          .field("inches", Int?.self),
        ] }

        public var feet: Int { __data["feet"] }
        public var inches: Int? { __data["inches"] }
        public var meters: Int { __data["meters"] }

        public init(
          feet: Int,
          inches: Int? = nil,
          meters: Int
        ) {
          let objectType = AnimalKingdomAPI.Objects.Height
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "feet": feet,
              "inches": inches,
              "meters": meters
          ]))
        }
      }

      /// AllAnimal.Predator
      ///
      /// Parent Type: `Animal`
      public struct Predator: AnimalKingdomAPI.SelectionSet {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("species", String.self),
          .inlineFragment(AsWarmBlooded.self),
        ] }

        public var species: String { __data["species"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

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

        /// AllAnimal.Predator.AsWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public typealias RootEntityType = AllAnimal.Predator
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("predators", [Predator].self),
            .field("laysEggs", Bool.self),
            .fragment(WarmBloodedDetails.self),
          ] }

          public var predators: [Predator] { __data["predators"] }
          public var laysEggs: Bool { __data["laysEggs"] }
          public var species: String { __data["species"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var height: HeightInMeters.Height { __data["height"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
          }

          public init(
            __typename: String,
            predators: [Predator],
            laysEggs: Bool,
            species: String,
            bodyTemperature: Int,
            height: HeightInMeters.Height
          ) {
            let objectType = ApolloAPI.Object(
              typename: __typename,
              implementedInterfaces: [
                AnimalKingdomAPI.Interfaces.Animal,
                AnimalKingdomAPI.Interfaces.WarmBlooded
            ])
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "predators": predators._fieldData,
                "laysEggs": laysEggs,
                "species": species,
                "bodyTemperature": bodyTemperature,
                "height": height._fieldData
            ]))
          }

          /// AllAnimal.Predator.AsWarmBlooded.Predator
          ///
          /// Parent Type: `Animal`
          public struct Predator: AnimalKingdomAPI.SelectionSet {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("species", String.self),
            ] }

            public var species: String { __data["species"] }

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
        }
      }

      /// AllAnimal.AsWarmBlooded
      ///
      /// Parent Type: `WarmBlooded`
      public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        public init(
          __typename: String,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator],
          bodyTemperature: Int
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.Animal,
              AnimalKingdomAPI.Interfaces.WarmBlooded
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "height": height._fieldData,
              "species": species,
              "skinCovering": skinCovering,
              "predators": predators._fieldData,
              "bodyTemperature": bodyTemperature
          ]))
        }

        /// AllAnimal.AsWarmBlooded.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }

          public init(
            feet: Int,
            inches: Int? = nil,
            meters: Int
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "feet": feet,
                "inches": inches,
                "meters": meters
            ]))
          }
        }
      }

      /// AllAnimal.AsPet
      ///
      /// Parent Type: `Pet`
      public struct AsPet: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("height", Height.self),
          .inlineFragment(AsWarmBlooded.self),
          .fragment(PetDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var petDetails: PetDetails { _toFragment() }
          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        public init(
          __typename: String,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator],
          humanName: String? = nil,
          favoriteToy: String,
          owner: PetDetails.Owner? = nil
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.Animal,
              AnimalKingdomAPI.Interfaces.Pet
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "height": height._fieldData,
              "species": species,
              "skinCovering": skinCovering,
              "predators": predators._fieldData,
              "humanName": humanName,
              "favoriteToy": favoriteToy,
              "owner": owner._fieldData
          ]))
        }

        /// AllAnimal.AsPet.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("relativeSize", GraphQLEnum<AnimalKingdomAPI.RelativeSize>.self),
            .field("centimeters", Double.self),
          ] }

          public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize> { __data["relativeSize"] }
          public var centimeters: Double { __data["centimeters"] }
          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }

          public init(
            relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
            centimeters: Double,
            feet: Int,
            inches: Int? = nil,
            meters: Int
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "relativeSize": relativeSize,
                "centimeters": centimeters,
                "feet": feet,
                "inches": inches,
                "meters": meters
            ]))
          }
        }

        /// AllAnimal.AsPet.AsWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public typealias RootEntityType = AllAnimal
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
          public static var __selections: [ApolloAPI.Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          public init(
            __typename: String,
            height: Height,
            species: String,
            skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
            predators: [Predator],
            bodyTemperature: Int,
            humanName: String? = nil,
            favoriteToy: String,
            owner: PetDetails.Owner? = nil
          ) {
            let objectType = ApolloAPI.Object(
              typename: __typename,
              implementedInterfaces: [
                AnimalKingdomAPI.Interfaces.Animal,
                AnimalKingdomAPI.Interfaces.Pet,
                AnimalKingdomAPI.Interfaces.WarmBlooded
            ])
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "height": height._fieldData,
                "species": species,
                "skinCovering": skinCovering,
                "predators": predators._fieldData,
                "bodyTemperature": bodyTemperature,
                "humanName": humanName,
                "favoriteToy": favoriteToy,
                "owner": owner._fieldData
            ]))
          }

          /// AllAnimal.AsPet.AsWarmBlooded.Height
          ///
          /// Parent Type: `Height`
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize> { __data["relativeSize"] }
            public var centimeters: Double { __data["centimeters"] }

            public init(
              feet: Int,
              inches: Int? = nil,
              meters: Int,
              relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
              centimeters: Double
            ) {
              let objectType = AnimalKingdomAPI.Objects.Height
              self.init(data: DataDict(
                objectType: objectType,
                data: [
                  "__typename": objectType.typename,
                  "feet": feet,
                  "inches": inches,
                  "meters": meters,
                  "relativeSize": relativeSize,
                  "centimeters": centimeters
              ]))
            }
          }
        }
      }

      /// AllAnimal.AsCat
      ///
      /// Parent Type: `Cat`
      public struct AsCat: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Cat }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { __data["isJellicle"] }
        public var height: Height { __data["height"] }
        public var species: String { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
        }

        public init(
          isJellicle: Bool,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator],
          bodyTemperature: Int,
          humanName: String? = nil,
          favoriteToy: String,
          owner: PetDetails.Owner? = nil
        ) {
          let objectType = AnimalKingdomAPI.Objects.Cat
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "isJellicle": isJellicle,
              "height": height._fieldData,
              "species": species,
              "skinCovering": skinCovering,
              "predators": predators._fieldData,
              "bodyTemperature": bodyTemperature,
              "humanName": humanName,
              "favoriteToy": favoriteToy,
              "owner": owner._fieldData
          ]))
        }

        /// AllAnimal.AsCat.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
          public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize> { __data["relativeSize"] }
          public var centimeters: Double { __data["centimeters"] }

          public init(
            feet: Int,
            inches: Int? = nil,
            meters: Int,
            relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
            centimeters: Double
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "feet": feet,
                "inches": inches,
                "meters": meters,
                "relativeSize": relativeSize,
                "centimeters": centimeters
            ]))
          }
        }
      }

      /// AllAnimal.AsClassroomPet
      ///
      /// Parent Type: `ClassroomPet`
      public struct AsClassroomPet: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
        public static var __selections: [ApolloAPI.Selection] { [
          .inlineFragment(AsBird.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public var asBird: AsBird? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        public init(
          __typename: String,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator]
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
              "height": height._fieldData,
              "species": species,
              "skinCovering": skinCovering,
              "predators": predators._fieldData
          ]))
        }

        /// AllAnimal.AsClassroomPet.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }

          public init(
            feet: Int,
            inches: Int? = nil,
            meters: Int
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "feet": feet,
                "inches": inches,
                "meters": meters
            ]))
          }
        }

        /// AllAnimal.AsClassroomPet.AsBird
        ///
        /// Parent Type: `Bird`
        public struct AsBird: AnimalKingdomAPI.InlineFragment {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public typealias RootEntityType = AllAnimal
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Bird }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("wingspan", Double.self),
          ] }

          public var wingspan: Double { __data["wingspan"] }
          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          public init(
            wingspan: Double,
            height: Height,
            species: String,
            skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
            predators: [Predator],
            bodyTemperature: Int,
            humanName: String? = nil,
            favoriteToy: String,
            owner: PetDetails.Owner? = nil
          ) {
            let objectType = AnimalKingdomAPI.Objects.Bird
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "wingspan": wingspan,
                "height": height._fieldData,
                "species": species,
                "skinCovering": skinCovering,
                "predators": predators._fieldData,
                "bodyTemperature": bodyTemperature,
                "humanName": humanName,
                "favoriteToy": favoriteToy,
                "owner": owner._fieldData
            ]))
          }

          /// AllAnimal.AsClassroomPet.AsBird.Height
          ///
          /// Parent Type: `Height`
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let __data: DataDict
            public init(_data: DataDict) { __data = data }

            public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize> { __data["relativeSize"] }
            public var centimeters: Double { __data["centimeters"] }

            public init(
              feet: Int,
              inches: Int? = nil,
              meters: Int,
              relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
              centimeters: Double
            ) {
              let objectType = AnimalKingdomAPI.Objects.Height
              self.init(data: DataDict(
                objectType: objectType,
                data: [
                  "__typename": objectType.typename,
                  "feet": feet,
                  "inches": inches,
                  "meters": meters,
                  "relativeSize": relativeSize,
                  "centimeters": centimeters
              ]))
            }
          }
        }
      }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Dog }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("favoriteToy", String.self),
          .field("birthdate", AnimalKingdomAPI.CustomDate?.self),
        ] }

        public var favoriteToy: String { __data["favoriteToy"] }
        public var birthdate: AnimalKingdomAPI.CustomDate? { __data["birthdate"] }
        public var height: Height { __data["height"] }
        public var species: String { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }
        public var humanName: String? { __data["humanName"] }
        public var owner: PetDetails.Owner? { __data["owner"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
        }

        public init(
          favoriteToy: String,
          birthdate: AnimalKingdomAPI.CustomDate? = nil,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator],
          bodyTemperature: Int,
          humanName: String? = nil,
          owner: PetDetails.Owner? = nil
        ) {
          let objectType = AnimalKingdomAPI.Objects.Dog
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "favoriteToy": favoriteToy,
              "birthdate": birthdate,
              "height": height._fieldData,
              "species": species,
              "skinCovering": skinCovering,
              "predators": predators._fieldData,
              "bodyTemperature": bodyTemperature,
              "humanName": humanName,
              "owner": owner._fieldData
          ]))
        }

        /// AllAnimal.AsDog.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
          public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize> { __data["relativeSize"] }
          public var centimeters: Double { __data["centimeters"] }

          public init(
            feet: Int,
            inches: Int? = nil,
            meters: Int,
            relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
            centimeters: Double
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "feet": feet,
                "inches": inches,
                "meters": meters,
                "relativeSize": relativeSize,
                "centimeters": centimeters
            ]))
          }
        }
      }
    }
  }
}
