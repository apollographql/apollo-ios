// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension MyGraphQLSchema {
  class AllAnimalsQuery: GraphQLQuery {
    public static let operationName: String = "AllAnimalsQuery"
    public static let document: DocumentType = .notPersisted(
      definition: .init(
        """
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
              __typename
              ...PetDetails
              ...WarmBloodedDetails
              ... on Animal {
                __typename
                height {
                  __typename
                  relativeSize
                  centimeters
                }
              }
            }
            ... on Cat {
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
            ... on Dog {
              __typename
              favoriteToy
              birthdate
            }
            predators {
              __typename
              species
              ... on WarmBlooded {
                __typename
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

    public struct Data: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyGraphQLSchema.Objects.Query }
      public static var __selections: [Selection] { [
        .field("allAnimals", [AllAnimal].self),
      ] }

      public var allAnimals: [AllAnimal] { __data["allAnimals"] }

      /// AllAnimal
      ///
      /// Parent Type: `Animal`
      public struct AllAnimal: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.Animal }
        public static var __selections: [Selection] { [
          .field("height", Height.self),
          .field("species", String.self),
          .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
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
        public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
        public var predators: [Predator] { __data["predators"] }

        public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }
        public var asPet: AsPet? { _asInlineFragment() }
        public var asCat: AsCat? { _asInlineFragment() }
        public var asClassroomPet: AsClassroomPet? { _asInlineFragment() }
        public var asDog: AsDog? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var heightInMeters: HeightInMeters { _toFragment() }
        }

        /// AllAnimal.Height
        ///
        /// Parent Type: `Height`
        public struct Height: MyGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }
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
        public struct Predator: MyGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.Animal }
          public static var __selections: [Selection] { [
            .field("species", String.self),
            .inlineFragment(AsWarmBlooded.self),
          ] }

          public var species: String { __data["species"] }

          public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

          /// AllAnimal.Predator.AsWarmBlooded
          ///
          /// Parent Type: `WarmBlooded`
          public struct AsWarmBlooded: MyGraphQLSchema.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.WarmBlooded }
            public static var __selections: [Selection] { [
              .field("laysEggs", Bool.self),
              .fragment(WarmBloodedDetails.self),
            ] }

            public var laysEggs: Bool { __data["laysEggs"] }
            public var species: String { __data["species"] }
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
        public struct AsWarmBlooded: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.WarmBlooded }
          public static var __selections: [Selection] { [
            .fragment(WarmBloodedDetails.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var heightInMeters: HeightInMeters { _toFragment() }
          }

          /// AllAnimal.AsWarmBlooded.Height
          ///
          /// Parent Type: `Height`
          public struct Height: MyGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
          }
        }

        /// AllAnimal.AsPet
        ///
        /// Parent Type: `Pet`
        public struct AsPet: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.Pet }
          public static var __selections: [Selection] { [
            .field("height", Height.self),
            .inlineFragment(AsWarmBlooded.self),
            .fragment(PetDetails.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
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
            public var heightInMeters: HeightInMeters { _toFragment() }
          }

          /// AllAnimal.AsPet.Height
          ///
          /// Parent Type: `Height`
          public struct Height: MyGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }
            public static var __selections: [Selection] { [
              .field("relativeSize", GraphQLEnum<RelativeSize>.self),
              .field("centimeters", Double.self),
            ] }

            public var relativeSize: GraphQLEnum<RelativeSize> { __data["relativeSize"] }
            public var centimeters: Double { __data["centimeters"] }
            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
          }

          /// AllAnimal.AsPet.AsWarmBlooded
          ///
          /// Parent Type: `WarmBlooded`
          public struct AsWarmBlooded: MyGraphQLSchema.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.WarmBlooded }
            public static var __selections: [Selection] { [
              .fragment(WarmBloodedDetails.self),
            ] }

            public var height: Height { __data["height"] }
            public var species: String { __data["species"] }
            public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
            public var predators: [Predator] { __data["predators"] }
            public var bodyTemperature: Int { __data["bodyTemperature"] }
            public var humanName: String? { __data["humanName"] }
            public var favoriteToy: String { __data["favoriteToy"] }
            public var owner: PetDetails.Owner? { __data["owner"] }

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
            public struct Height: MyGraphQLSchema.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

              public var feet: Int { __data["feet"] }
              public var inches: Int? { __data["inches"] }
              public var meters: Int { __data["meters"] }
              public var relativeSize: GraphQLEnum<RelativeSize> { __data["relativeSize"] }
              public var centimeters: Double { __data["centimeters"] }
            }
          }
        }

        /// AllAnimal.AsCat
        ///
        /// Parent Type: `Cat`
        public struct AsCat: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Objects.Cat }
          public static var __selections: [Selection] { [
            .field("isJellicle", Bool.self),
          ] }

          public var isJellicle: Bool { __data["isJellicle"] }
          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var humanName: String? { __data["humanName"] }
          public var favoriteToy: String { __data["favoriteToy"] }
          public var owner: PetDetails.Owner? { __data["owner"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          /// AllAnimal.AsCat.Height
          ///
          /// Parent Type: `Height`
          public struct Height: MyGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<RelativeSize> { __data["relativeSize"] }
            public var centimeters: Double { __data["centimeters"] }
          }
        }

        /// AllAnimal.AsClassroomPet
        ///
        /// Parent Type: `ClassroomPet`
        public struct AsClassroomPet: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Unions.ClassroomPet }
          public static var __selections: [Selection] { [
            .inlineFragment(AsBird.self),
          ] }

          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }

          public var asBird: AsBird? { _asInlineFragment() }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
          }

          /// AllAnimal.AsClassroomPet.Height
          ///
          /// Parent Type: `Height`
          public struct Height: MyGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
          }

          /// AllAnimal.AsClassroomPet.AsBird
          ///
          /// Parent Type: `Bird`
          public struct AsBird: MyGraphQLSchema.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Bird }
            public static var __selections: [Selection] { [
              .field("wingspan", Double.self),
            ] }

            public var wingspan: Double { __data["wingspan"] }
            public var height: Height { __data["height"] }
            public var species: String { __data["species"] }
            public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
            public var predators: [Predator] { __data["predators"] }
            public var bodyTemperature: Int { __data["bodyTemperature"] }
            public var humanName: String? { __data["humanName"] }
            public var favoriteToy: String { __data["favoriteToy"] }
            public var owner: PetDetails.Owner? { __data["owner"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public var heightInMeters: HeightInMeters { _toFragment() }
              public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
              public var petDetails: PetDetails { _toFragment() }
            }

            /// AllAnimal.AsClassroomPet.AsBird.Height
            ///
            /// Parent Type: `Height`
            public struct Height: MyGraphQLSchema.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

              public var feet: Int { __data["feet"] }
              public var inches: Int? { __data["inches"] }
              public var meters: Int { __data["meters"] }
              public var relativeSize: GraphQLEnum<RelativeSize> { __data["relativeSize"] }
              public var centimeters: Double { __data["centimeters"] }
            }
          }
        }

        /// AllAnimal.AsDog
        ///
        /// Parent Type: `Dog`
        public struct AsDog: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { MyGraphQLSchema.Objects.Dog }
          public static var __selections: [Selection] { [
            .field("favoriteToy", String.self),
            .field("birthdate", CustomDate?.self),
          ] }

          public var favoriteToy: String { __data["favoriteToy"] }
          public var birthdate: CustomDate? { __data["birthdate"] }
          public var height: Height { __data["height"] }
          public var species: String { __data["species"] }
          public var skinCovering: GraphQLEnum<SkinCovering>? { __data["skinCovering"] }
          public var predators: [Predator] { __data["predators"] }
          public var bodyTemperature: Int { __data["bodyTemperature"] }
          public var humanName: String? { __data["humanName"] }
          public var owner: PetDetails.Owner? { __data["owner"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var heightInMeters: HeightInMeters { _toFragment() }
            public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
            public var petDetails: PetDetails { _toFragment() }
          }

          /// AllAnimal.AsDog.Height
          ///
          /// Parent Type: `Height`
          public struct Height: MyGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }

            public var feet: Int { __data["feet"] }
            public var inches: Int? { __data["inches"] }
            public var meters: Int { __data["meters"] }
            public var relativeSize: GraphQLEnum<RelativeSize> { __data["relativeSize"] }
            public var centimeters: Double { __data["centimeters"] }
          }
        }
      }
    }
  }

}