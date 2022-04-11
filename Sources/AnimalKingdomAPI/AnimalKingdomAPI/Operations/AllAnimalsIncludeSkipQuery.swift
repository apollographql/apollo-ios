// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class AllAnimalsIncludeSkipQuery: GraphQLQuery {
  public let operationName: String = "AllAnimalsIncludeSkipQuery"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
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
      """,
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

  public var variables: Variables? {
    ["includeSpecies": includeSpecies,
     "skipHeightInMeters": skipHeightInMeters,
     "getCat": getCat,
     "getWarmBlooded": getWarmBlooded,
     "varA": varA]
  }

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { data["allAnimals"] }

    /// AllAnimal
    public struct AllAnimal: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("height", Height.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .field("predators", [Predator].self),
        .inlineFragment(AsPet.self),
        .inlineFragment(AsClassroomPet.self),
        .include(if: "includeSpecies", .field("species", String.self)),
        .include(if: "getWarmBlooded", .inlineFragment(AsWarmBlooded.self)),
        .include(if: "getCat", .inlineFragment(AsCat.self)),
        .include(if: !"skipHeightInMeters", .fragment(HeightInMeters.self)),
      ] }

      public var height: Height { data["height"] }
      public var species: String? { data["species"] }
      public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
      public var predators: [Predator] { data["predators"] }

      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }
      public var asPet: AsPet? { _asInlineFragment() }
      public var asCat: AsCat? { _asInlineFragment(if: "getCat") }
      public var asClassroomPet: AsClassroomPet? { _asInlineFragment() }
      public var ifNotSkipHeightInMeters: IfNotSkipHeightInMeters? { _asInlineFragment(if: !"skipHeightInMeters") }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var heightInMeters: HeightInMeters? { _toFragment() }
      }

      /// AllAnimal.Height
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
      }

      /// AllAnimal.Predator
      public struct Predator: AnimalKingdomAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
        public static var selections: [Selection] { [
          .include(if: "includeSpecies", .field("species", String.self)),
          .include(if: "getWarmBlooded", .inlineFragment(AsWarmBlooded.self)),
        ] }

        public var species: String? { data["species"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }

        /// AllAnimal.Predator.AsWarmBlooded
        public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
          public static var selections: [Selection] { [
            .field("species", String.self),
            .fragment(WarmBloodedDetails.self),
            .field("laysEggs", Bool.self),
          ] }

          public var species: String { data["species"] }
          public var laysEggs: Bool { data["laysEggs"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }
          public var height: WarmBloodedDetails.Height { data["height"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }
        }
      }

      /// AllAnimal.AsWarmBlooded
      public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
        public static var selections: [Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String? { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }

        public var ifGetWarmBlooded: IfGetWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var heightInMeters: HeightInMeters? { _toFragment() }
        }

        /// AllAnimal.AsWarmBlooded.Height
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
          public var yards: Int { data["yards"] }
        }

        /// AllAnimal.AsWarmBlooded.IfGetWarmBlooded
        public struct IfGetWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }

          public var height: Height { data["height"] }
          public var species: String? { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predator] { data["predators"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var heightInMeters: HeightInMeters? { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }

          /// AllAnimal.AsWarmBlooded.IfGetWarmBlooded.Height
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

            public var feet: Int { data["feet"] }
            public var inches: Int { data["inches"] }
            public var meters: Int { data["meters"] }
            public var yards: Int { data["yards"] }
          }
        }
      }

      /// AllAnimal.AsPet
      public struct AsPet: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
        public static var selections: [Selection] { [
          .field("height", Height.self),
          .inlineFragment(AsWarmBlooded.self),
          .fragment(PetDetails.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String? { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Owner? { data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var petDetails: PetDetails { _toFragment() }
          public var heightInMeters: HeightInMeters? { _toFragment() }
        }

        /// AllAnimal.AsPet.Height
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
          public static var selections: [Selection] { [
            .include(if: "varA", [
              .field("relativeSize", GraphQLEnum<RelativeSize>.self),
              .field("centimeters", Int.self),
            ]),
          ] }

          public var relativeSize: GraphQLEnum<RelativeSize>? { data["relativeSize"] }
          public var centimeters: Int? { data["centimeters"] }
          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
        }

        /// AllAnimal.AsPet.AsWarmBlooded
        public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
          public static var selections: [Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { data["height"] }
          public var species: String? { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predator] { data["predators"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Owner? { data["owner"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters? { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          /// AllAnimal.AsPet.AsWarmBlooded.Height
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

            public var feet: Int { data["feet"] }
            public var inches: Int { data["inches"] }
            public var meters: Int { data["meters"] }
            public var yards: Int { data["yards"] }
            public var relativeSize: GraphQLEnum<RelativeSize>? { data["relativeSize"] }
            public var centimeters: Int? { data["centimeters"] }
          }
        }
      }

      /// AllAnimal.AsCat
      public struct AsCat: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
        public static var selections: [Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { data["isJellicle"] }
        public var height: Height { data["height"] }
        public var species: String? { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }
        public var humanName: String? { data["humanName"] }
        public var favoriteToy: String { data["favoriteToy"] }
        public var owner: PetDetails.Owner? { data["owner"] }
        public var bodyTemperature: Int { data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heightInMeters: HeightInMeters? { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
        }

        /// AllAnimal.AsCat.Height
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
          public var yards: Int { data["yards"] }
          public var relativeSize: GraphQLEnum<RelativeSize>? { data["relativeSize"] }
          public var centimeters: Int? { data["centimeters"] }
        }
      }

      /// AllAnimal.AsClassroomPet
      public struct AsClassroomPet: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
        public static var selections: [Selection] { [
          .inlineFragment(AsBird.self),
        ] }

        public var height: Height { data["height"] }
        public var species: String? { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }

        public var asBird: AsBird? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heightInMeters: HeightInMeters? { _toFragment() }
        }

        /// AllAnimal.AsClassroomPet.AsBird
        public struct AsBird: AnimalKingdomAPI.InlineFragment {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
          public static var selections: [Selection] { [
            .field("wingspan", Float.self),
          ] }

          public var wingspan: Float { data["wingspan"] }
          public var height: Height { data["height"] }
          public var species: String? { data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
          public var predators: [Predator] { data["predators"] }
          public var humanName: String? { data["humanName"] }
          public var favoriteToy: String { data["favoriteToy"] }
          public var owner: PetDetails.Owner? { data["owner"] }
          public var bodyTemperature: Int { data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var heightInMeters: HeightInMeters? { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }

          /// AllAnimal.AsClassroomPet.AsBird.Height
          public struct Height: AnimalKingdomAPI.SelectionSet {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

            public var feet: Int { data["feet"] }
            public var inches: Int { data["inches"] }
            public var meters: Int { data["meters"] }
            public var yards: Int { data["yards"] }
            public var relativeSize: GraphQLEnum<RelativeSize>? { data["relativeSize"] }
            public var centimeters: Int? { data["centimeters"] }
          }
        }
      }
      /// AllAnimal.IfNotSkipHeightInMeters
      public struct IfNotSkipHeightInMeters: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }

        public var height: Height { data["height"] }
        public var species: String? { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
        public var predators: [Predator] { data["predators"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        /// AllAnimal.IfNotSkipHeightInMeters.Height
        public struct Height: AnimalKingdomAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }

          public var feet: Int { data["feet"] }
          public var inches: Int { data["inches"] }
          public var meters: Int { data["meters"] }
        }
      }
    }
  }
}