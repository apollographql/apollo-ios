// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HumanQuery: GraphQLQuery {
  public let operationName: String = "Human"
  public let document: DocumentType = .notPersisted(
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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("human", Human?.self, arguments: ["id": .variable("id")]),
    ] }

    public var human: Human? { data["human"] }

    /// Human
    public struct Human: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("mass", Float?.self),
      ] }

      public var name: String { data["name"] }
      public var mass: Float? { data["mass"] }
    }
  }
}