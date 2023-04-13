// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query DogQuery {
        allAnimals {
          __typename
          id
          skinCovering
          ... on Dog {
            ...DogFragment
          }
        }
      }
      """#,
      fragments: [DogFragment.self]
    ))

  public init() {}

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
      self.init(_dataDict: DataDict(data: [
        "__typename": AnimalKingdomAPI.Objects.Query.typename,
        "allAnimals": allAnimals._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
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
        .field("__typename", String.self),
        .field("id", AnimalKingdomAPI.ID.self),
        .field("skinCovering", GraphQLEnum<AnimalKingdomAPI.SkinCovering>?.self),
        .inlineFragment(AsDog.self),
      ] }

      public var id: AnimalKingdomAPI.ID { __data["id"] }
      public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }

      public var asDog: AsDog? { _asInlineFragment() }

      public init(
        __typename: String,
        id: AnimalKingdomAPI.ID,
        skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "id": id,
          "skinCovering": skinCovering,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Dog }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(DogFragment.self),
        ] }

        public var id: AnimalKingdomAPI.ID { __data["id"] }
        public var skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? { __data["skinCovering"] }
        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var dogFragment: DogFragment { _toFragment() }
        }

        public init(
          id: AnimalKingdomAPI.ID,
          skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
          species: String
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": AnimalKingdomAPI.Objects.Dog.typename,
            "id": id,
            "skinCovering": skinCovering,
            "species": species,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.self),
              ObjectIdentifier(DogFragment.self)
            ])
          ]))
        }
      }
    }
  }
}
