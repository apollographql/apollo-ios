// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameWithIDQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameWithID"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "83c03f612c46fca72f6cb902df267c57bffc9209bc44dd87d2524fb2b34f6f18",
    definition: .init(
      #"""
      query HeroNameWithID($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
          name
        }
      }
      """#
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var __variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
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
