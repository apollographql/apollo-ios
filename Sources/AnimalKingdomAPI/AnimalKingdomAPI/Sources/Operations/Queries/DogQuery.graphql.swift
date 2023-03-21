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
    public init(_data: DataDict) { __data = _data }

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
      public init(_data: DataDict) { __data = _data }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", AnimalKingdomAPI.ID.self),
        .inlineFragment(AsDog.self),
      ] }

      public var id: AnimalKingdomAPI.ID { __data["id"] }

      public var asDog: AsDog? { _asInlineFragment() }

      public init(
        __typename: String,
        id: AnimalKingdomAPI.ID
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
            "id": id
        ]))
      }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = _data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Dog }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(DogFragment.self),
        ] }

        public var id: AnimalKingdomAPI.ID { __data["id"] }
        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = _data }

          public var dogFragment: DogFragment { _toFragment() }
        }

        public init(
          id: AnimalKingdomAPI.ID,
          species: String
        ) {
          let objectType = AnimalKingdomAPI.Objects.Dog
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "id": id,
              "species": species
          ]))
        }
      }
    }
  }
}
