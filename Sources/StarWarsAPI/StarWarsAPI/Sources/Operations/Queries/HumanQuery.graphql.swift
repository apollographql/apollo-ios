// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HumanQuery: GraphQLQuery {
  public static let operationName: String = "Human"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "b37eb69b82fd52358321e49453769750983be1c286744dbf415735d7bcf12f1e",
    definition: .init(
      #"""
      query Human($id: ID!) {
        human(id: $id) {
          __typename
          name
          mass
        }
      }
      """#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("human", Human?.self, arguments: ["id": .variable("id")]),
    ] }

    public var human: Human? { __data["human"] }

    public init(
      human: Human? = nil
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": StarWarsAPI.Objects.Query.typename,
        "human": human._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }

    /// Human
    ///
    /// Parent Type: `Human`
    public struct Human: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("mass", Double?.self),
      ] }

      /// What this human calls themselves
      public var name: String { __data["name"] }
      /// Mass in kilograms, or null if unknown
      public var mass: Double? { __data["mass"] }

      public init(
        name: String,
        mass: Double? = nil
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": StarWarsAPI.Objects.Human.typename,
          "name": name,
          "mass": mass,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }
    }
  }
}
