// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameWithIDQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameWithID"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "83c03f612c46fca72f6cb902df267c57bffc9209bc44dd87d2524fb2b34f6f18",
    definition: .init(
      """
      query HeroNameWithID($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
          name
        }
      }
      """
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var variables: Variables? {
    ["episode": episode]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .field("name", String.self),
      ] }

      /// The ID of the character
      public var id: ID { __data["id"] }
      /// The name of the character
      public var name: String { __data["name"] }
    }
  }
}
