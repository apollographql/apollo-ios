// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllAnimalsIncludeSkipQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsIncludeSkipQuery"
  public static let document: DocumentType = .notPersisted(
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
            __typename
            ...PetDetails
            ...WarmBloodedDetails
            ... on Animal {
              __typename
              height {
                __typename
                relativeSize @include(if: $varA)
                centimeters @include(if: $varA)
              }
            }
          }
          ... on Cat @include(if: $getCat) {
            __typename
            isJellicle
          }
          ... on ClassroomPet {
            __typename
            ... on Bird {
              __typename
              wingspan
            }
          }
          predators {
            __typename
            species @include(if: $includeSpecies)
            ... on WarmBlooded @include(if: $getWarmBlooded) {
              __typename
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

  public var __variables: Variables? { [
    "includeSpecies": includeSpecies,
    "skipHeightInMeters": skipHeightInMeters,
    "getCat": getCat,
    "getWarmBlooded": getWarmBlooded,
    "varA": varA
  ] }

  public struct Data: GraphQLAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { GraphQLAPI.Objects.Query }
    public static var __selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: GraphQLAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { GraphQLAPI.Interfaces.Animal }
      public static var __selections: [Selection] { [
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

      public var height: Height { __data["height"] }
      public var species: String? { __data["species"] }
      public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
      public var predators: [Predator] { __data["predators"] }

      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }
      public var asPet: AsPet? { _asInlineFragment() }
      public var asCat: AsCat? { _asInlineFragment(if: "getCat") }
      public var asClassroomPet: AsClassroomPet? { _asInlineFragment() }
      public var ifNotSkipHeightInMeters: IfNotSkipHeightInMeters? { _asInlineFragment(if: !"skipHeightInMeters") }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
      }

      /// AllAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: GraphQLAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Objects.Height }
        public static var __selections: [Selection] { [
          .field("feet", Int.self),
          .field("inches", Int?.self),
        ] }

        public var feet: Int { __data["feet"] }
        public var inches: Int? { __data["inches"] }
        public var meters: Int { __data["meters"] }
      }

      /// AllAnimal.Predator
      ///
      /// Parent Type: `Animal`
      public struct Predator: GraphQLAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Interfaces.Animal }
        public static var __selections: [Selection] { [
          .include(if: "includeSpecies", .field("species", String.self)),
          .include(if: "getWarmBlooded", .inlineFragment(AsWarmBlooded.self)),
        ] }

        public var species: String? { __data["species"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }

        /// AllAnimal.Predator.AsWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct AsWarmBlooded: GraphQLAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Interfaces.WarmBlooded }
          public static var __selections: [Selection] { [
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
            public init(data: DataDict) { __data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
          }
        }
      }

      /// AllAnimal.AsWarmBlooded
      ///
      /// Parent Type: `WarmBlooded`
      public struct AsWarmBlooded: GraphQLAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Interfaces.WarmBlooded }
        public static var __selections: [Selection] { [
          .fragment(WarmBloodedDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }

        public var ifGetWarmBlooded: IfGetWarmBlooded? { _asInlineFragment(if: "getWarmBlooded") }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        /// AllAnimal.AsWarmBlooded.Height
        ///
        /// Parent Type: `Height`
        public struct Height: GraphQLAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
        }

        /// AllAnimal.AsWarmBlooded.IfGetWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct IfGetWarmBlooded: GraphQLAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Interfaces.WarmBlooded }

          public var height: Height { __data["height"] }
          public var species: String? { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }

          /// AllAnimal.AsWarmBlooded.IfGetWarmBlooded.Height
          ///
          /// Parent Type: `Height`
          public struct Height: GraphQLAPI.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
          }
        }
      }

      /// AllAnimal.AsPet
      ///
      /// Parent Type: `Pet`
      public struct AsPet: GraphQLAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Interfaces.Pet }
        public static var __selections: [Selection] { [
          .field("height", Height.self),
          .inlineFragment(AsWarmBlooded.self),
          .fragment(PetDetails.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var petDetails: PetDetails { _toFragment() }
          public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
        }

        /// AllAnimal.AsPet.Height
        ///
        /// Parent Type: `Height`
        public struct Height: GraphQLAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Height }
          public static var __selections: [Selection] { [
            .include(if: "varA", [
              .field("relativeSize", GraphQLEnum<RelativeSize>.self),
              .field("centimeters", Double.self),
            ]),
          ] }

          public var relativeSize: GraphQLEnum<RelativeSize>? { __data["relativeSize"] }
          public var centimeters: Double? { __data["centimeters"] }
          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
        }

        /// AllAnimal.AsPet.AsWarmBlooded
        ///
        /// Parent Type: `WarmBlooded`
        public struct AsWarmBlooded: GraphQLAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Interfaces.WarmBlooded }
          public static var __selections: [Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String? { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          /// AllAnimal.AsPet.AsWarmBlooded.Height
          ///
          /// Parent Type: `Height`
          public struct Height: GraphQLAPI.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<RelativeSize>? { __data["relativeSize"] }
            public var centimeters: Double? { __data["centimeters"] }
          }
        }
      }

      /// AllAnimal.AsCat
      ///
      /// Parent Type: `Cat`
      public struct AsCat: GraphQLAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Objects.Cat }
        public static var __selections: [Selection] { [
          .field("isJellicle", Bool.self),
        ] }

        public var isJellicle: Bool { __data["isJellicle"] }
        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }
        public var humanName: String? { __data["humanName"] }
        public var favoriteToy: String { __data["favoriteToy"] }
        public var owner: PetDetails.Owner? { __data["owner"] }
        public var bodyTemperature: Int { __data["bodyTemperature"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
          public var petDetails: PetDetails { _toFragment() }
          public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
        }

        /// AllAnimal.AsCat.Height
        ///
        /// Parent Type: `Height`
        public struct Height: GraphQLAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
          public var relativeSize: GraphQLEnum<RelativeSize>? { __data["relativeSize"] }
          public var centimeters: Double? { __data["centimeters"] }
        }
      }

      /// AllAnimal.AsClassroomPet
      ///
      /// Parent Type: `ClassroomPet`
      public struct AsClassroomPet: GraphQLAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Unions.ClassroomPet }
        public static var __selections: [Selection] { [
          .inlineFragment(AsBird.self),
        ] }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public var asBird: AsBird? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters? { _toFragment(if: !"skipHeightInMeters") }
        }

        /// AllAnimal.AsClassroomPet.Height
        ///
        /// Parent Type: `Height`
        public struct Height: GraphQLAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
        }

        /// AllAnimal.AsClassroomPet.AsBird
        ///
        /// Parent Type: `Bird`
        public struct AsBird: GraphQLAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Bird }
          public static var __selections: [Selection] { [
            .field("wingspan", Double.self),
          ] }

          public var wingspan: Double { __data["wingspan"] }
          public var height: Height { __data["height"] }
          public var species: String? { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
          }

          /// AllAnimal.AsClassroomPet.AsBird.Height
          ///
          /// Parent Type: `Height`
          public struct Height: GraphQLAPI.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<RelativeSize>? { __data["relativeSize"] }
            public var centimeters: Double? { __data["centimeters"] }
          }
        }
      }
      /// AllAnimal.IfNotSkipHeightInMeters
      ///
      /// Parent Type: `Animal`
      public struct IfNotSkipHeightInMeters: GraphQLAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { GraphQLAPI.Interfaces.Animal }

        public var height: Height { __data["height"] }
        public var species: String? { __data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        /// AllAnimal.IfNotSkipHeightInMeters.Height
        ///
        /// Parent Type: `Height`
        public struct Height: GraphQLAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { GraphQLAPI.Objects.Height }

          public var feet: Int { __data["feet"] }
          public var inches: Int? { __data["inches"] }
          public var meters: Int { __data["meters"] }
        }
      }
    }
  }
}
