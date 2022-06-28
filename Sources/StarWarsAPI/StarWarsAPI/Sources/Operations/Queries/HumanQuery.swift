// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HumanQuery: GraphQLQuery {
  public static let operationName: String = "Human"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "b37eb69b82fd52358321e49453769750983be1c286744dbf415735d7bcf12f1e",
    definition: .init(
      """
      query Human($id: ID!) {
        human(id: $id) {
          __typename
          name
          mass
        }
      }
      """
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var variables: Variables? {
    ["id": id]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("human", Human?.self, arguments: ["id": .variable("id")]),
    ] }

    public var human: Human? { __data["human"] }

    /// Human
    public struct Human: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("mass", Double?.self),
      ] }

      public var name: String { __data["name"] }
      public var mass: Double? { __data["mass"] }
    }
  }
}