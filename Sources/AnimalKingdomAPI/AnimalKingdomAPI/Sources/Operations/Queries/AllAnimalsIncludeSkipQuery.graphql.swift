// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllAnimalsIncludeSkipQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsIncludeSkipQuery"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query AllAnimalsIncludeSkipQuery($includeSpecies: Boolean!, $skipHeightInMeters: Boolean!, $getCat: Boolean!, $getWarmBlooded: Boolean!, $varA: Boolean!) {
        allAnimals {
          __typename
          height {
            __typename
            feet
            inches
          }
          ...HeightInMeters @skip(if: $skipHeightInMeters)
          ...WarmBloodedDetails @include(if: $getWarmBlooded)
          species @include(if: $includeSpecies)
          skinCovering
          ... on Pet {
            ...PetDetails
            ...WarmBloodedDetails
            ... on Animal {
              height {
                __typename
                relativeSize @include(if: $varA)
                centimeters @include(if: $varA)
              }
            }
          }
          ... on Cat @include(if: $getCat) {
            isJellicle
          }
          ... on ClassroomPet {
            ... on Bird {
              wingspan
            }
          }
          predators {
            __typename
            species @include(if: $includeSpecies)
            ... on WarmBlooded @include(if: $getWarmBlooded) {
              species
              ...WarmBloodedDetails
              laysEggs @include(if: $getWarmBlooded)
            }
          }
        }
      }
      """#,
      fragments: [HeightInMeters.self, WarmBloodedDetails.self, PetDetails.self]
    ))

  public var includeSpecies: Bool
  public var skipHeightInMeters: Bool
  public var getCat: Bool
  public var getWarmBlooded: Bool
  public var varA: Bool

  public init(
    includeSpecies: Bool,
    skipHeightInMeters: Bool,
    getCat: Bool,
    getWarmBlooded: Bool,
    varA: Bool
  ) {
    self.includeSpecies = includeSpecies
    self.skipHeightInMeters = skipHeightInMeters
    self.getCat = getCat
    self.getWarmBlooded = getWarmBlooded
    self.varA = varA
  }

  public var __variables: Variables? { [
    "includeSpecies": includeSpecies,
    "skipHeightInMeters": skipHeightInMeters,
    "getCat": getCat,
    "getWarmBlooded": getWarmBlooded,
    "varA": varA
  ] }

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("height", Height.self),
        .field("skinCovering", GraphQLEnum<AnimalKingdomAPI.SkinCovering>?.self),
        .field("predators", [Predator].self),
        .inlineFragment(AsPet.self),
        .inlineFragment(AsClassroomPet.self),
        .include(if: "includeSpecies", .field("species", String.self)),
        .include(if: "getWarmBlooded", .inlineFragment(AsWarmBlooded.self)),
        .include(if: "getCat", .inlineFragment(AsCat.self)),
        .include(if: !"skipHeightInMeters", .fragment(HeightInMeters.self)),
      ] }

      public var height: Height { __data["height"] }
      public var species: String? { __data["species"] }
      public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
      public var predators: [Predator] { __data["predators"] }

      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }
      public var asPet: AsPet? { _asInlineFragment() }
      public var asCat: AsCat? { _asInlineFragment(if: "getCat") }
      public var asClassroomPet: AsClassroomPet? { _asInlineFragment() }
      public var ifNotSkipHeightInMeters: IfNotSkipHeightInMeters? { _asInlineFragment(if: !"skipHeightInMeters") }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
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
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("feet", Int.self),
          .field("inches", Int?.self),
        ] }

        public var feet: Int { __data["feet"] }
        public var inches: Int? { __data["inches"] }

        public init(
          feet: Int,
          inches: Int? = nil
        ) {
          let objectType = AnimalKingdomAPI.Objects.Height
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "feet": feet,
              "inches": inches
          ]))
        }
      }

      /// AllAnimal.Predator
      ///
      /// Parent Type: `Animal`
      public struct Predator: AnimalKingdomAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
        public static var __selections: [ApolloAPI.Selection] { [
          .include(if: "includeSpecies", .field("species", String.self)),
          .include(if: "getWarmBlooded", .inlineFragment(AsWarmBlooded.self)),
        ] }

        public var species: String? { __data["species"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }

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
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AllAnimal.Predator
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("species", String.self),
            .fragment(WarmBloodedDetails.self),
            .field("laysEggs", Bool.self),
          ] }

          public var species: String { __data["species"] }
          public var laysEggs: Bool { __data["laysEggs"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var height: HeightInMeters.Height { __data["height"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
          }

          public init(
            __typename: String,
            species: String,
            laysEggs: Bool,
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
                "species": species,
                "laysEggs": laysEggs,
                "bodyTemperature": bodyTemperature,
                "height": height._fieldData
              ],
              variables: [
                "getWarmBlooded": true
            ]))
          }
        }
      }

      /// AllAnimal.AsWarmBlooded
      ///
      /// Parent Type: `WarmBlooded`
      public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

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
            ],
            variables: [
              "getWarmBlooded": true
          ]))
        }

        /// AllAnimal.AsWarmBlooded.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

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
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("height", Height.self),
          .inlineFragment(AsWarmBlooded.self),
          .fragment(PetDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var petDetails: PetDetails { _toFragment() }
          public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
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
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
          public static var __selections: [ApolloAPI.Selection] { [
            .include(if: "varA", [
              .field("relativeSize", GraphQLEnum<AnimalKingdomAPI.RelativeSize>.self),
              .field("centimeters", Double.self),
            ]),
          ] }

          public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>? { __data["relativeSize"] }
          public var centimeters: Double? { __data["centimeters"] }
          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }

          public init(
            relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
            centimeters: Double,
            feet: Int,
            inches: Int? = nil
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "relativeSize": relativeSize,
                "centimeters": centimeters,
                "feet": feet,
                "inches": inches
            ]))
          }
        }

        /// AllAnimal.AsPet.AsWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AllAnimal
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
          public static var __selections: [ApolloAPI.Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String? { __data["species"] }
          public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

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
            humanName: String? = nil,
            favoriteToy: String,
            owner: PetDetails.Owner? = nil,
            bodyTemperature: Int
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
                "humanName": humanName,
                "favoriteToy": favoriteToy,
                "owner": owner._fieldData,
                "bodyTemperature": bodyTemperature
            ]))
          }

          /// AllAnimal.AsPet.AsWarmBlooded.Height
          ///
          /// Parent Type: `Height`
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>? { __data["relativeSize"] }
            public var centimeters: Double? { __data["centimeters"] }
            public var meters: Int { __data["meters"] }

            public init(
              feet: Int,
              inches: Int? = nil,
              relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
              centimeters: Double,
              meters: Int
            ) {
              let objectType = AnimalKingdomAPI.Objects.Height
              self.init(data: DataDict(
                objectType: objectType,
                data: [
                  "__typename": objectType.typename,
                  "feet": feet,
                  "inches": inches,
                  "relativeSize": relativeSize,
                  "centimeters": centimeters,
                  "meters": meters
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
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Cat }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { __data["isJellicle"] }
        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
        }

        public init(
          isJellicle: Bool,
          height: Height,
          species: String,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          predators: [Predator],
          humanName: String? = nil,
          favoriteToy: String,
          owner: PetDetails.Owner? = nil,
          bodyTemperature: Int
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
              "humanName": humanName,
              "favoriteToy": favoriteToy,
              "owner": owner._fieldData,
              "bodyTemperature": bodyTemperature
            ],
            variables: [
              "getCat": true
          ]))
        }

        /// AllAnimal.AsCat.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>? { __data["relativeSize"] }
          public var centimeters: Double? { __data["centimeters"] }
          public var meters: Int { __data["meters"] }

          public init(
            feet: Int,
            inches: Int? = nil,
            relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
            centimeters: Double,
            meters: Int
          ) {
            let objectType = AnimalKingdomAPI.Objects.Height
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "feet": feet,
                "inches": inches,
                "relativeSize": relativeSize,
                "centimeters": centimeters,
                "meters": meters
            ]))
          }
        }
      }

      /// AllAnimal.AsClassroomPet
      ///
      /// Parent Type: `ClassroomPet`
      public struct AsClassroomPet: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
        public static var __selections: [ApolloAPI.Selection] { [
          .inlineFragment(AsBird.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public var asBird: AsBird? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
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

        /// AllAnimal.AsClassroomPet.AsBird
        ///
        /// Parent Type: `Bird`
        public struct AsBird: AnimalKingdomAPI.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AllAnimal
          public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Bird }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("wingspan", Double.self),
          ] }

          public var wingspan: Double { __data["wingspan"] }
          public var height: Height { __data["height"] }
          public var species: String? { __data["species"] }
          public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }

          public init(
            wingspan: Double,
            height: Height,
            species: String,
            skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
            predators: [Predator],
            humanName: String? = nil,
            favoriteToy: String,
            owner: PetDetails.Owner? = nil,
            bodyTemperature: Int
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
                "humanName": humanName,
                "favoriteToy": favoriteToy,
                "owner": owner._fieldData,
                "bodyTemperature": bodyTemperature
            ]))
          }

          /// AllAnimal.AsClassroomPet.AsBird.Height
          ///
          /// Parent Type: `Height`
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>? { __data["relativeSize"] }
            public var centimeters: Double? { __data["centimeters"] }
            public var meters: Int { __data["meters"] }

            public init(
              feet: Int,
              inches: Int? = nil,
              relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>,
              centimeters: Double,
              meters: Int
            ) {
              let objectType = AnimalKingdomAPI.Objects.Height
              self.init(data: DataDict(
                objectType: objectType,
                data: [
                  "__typename": objectType.typename,
                  "feet": feet,
                  "inches": inches,
                  "relativeSize": relativeSize,
                  "centimeters": centimeters,
                  "meters": meters
              ]))
            }
          }
        }
      }
      /// AllAnimal.IfNotSkipHeightInMeters
      ///
      /// Parent Type: `Animal`
      public struct IfNotSkipHeightInMeters: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

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
            ],
            variables: [
              "skipHeightInMeters": false
          ]))
        }

        /// AllAnimal.IfNotSkipHeightInMeters.Height
        ///
        /// Parent Type: `Height`
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

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
    }
  }
}
