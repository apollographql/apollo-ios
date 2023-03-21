// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllAnimalsCCNQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsCCN"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query AllAnimalsCCN {
        allAnimals {
          __typename
          height? {
            __typename
            feet?
            inches!
          }
        }
      }
      """#
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
        .field("height", Height?.self),
      ] }

      public var height: Height? { __data["height"] }

      public init(
        __typename: String,
        height: Height? = nil
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
            "height": height._fieldData
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
          .field("feet", Int?.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int? { __data["feet"] }
        public var inches: Int { __data["inches"] }

        public init(
          feet: Int? = nil,
          inches: Int
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
    }
  }
}
