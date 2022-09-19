// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class ReviewAddedSubscription: GraphQLSubscription {
  public static let operationName: String = "ReviewAdded"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "38644c5e7cf4fd506b91d2e7010cabf84e63dfcd33cf1deb443b4b32b55e2cbe",
    definition: .init(
      """
      subscription ReviewAdded($episode: Episode) {
        reviewAdded(episode: $episode) {
          __typename
          episode
          stars
          commentary
        }
      }
      """
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var _variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Subscription }
    public static var __selections: [Selection] { [
      .field("reviewAdded", ReviewAdded?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var reviewAdded: ReviewAdded? { __data["reviewAdded"] }

    /// ReviewAdded
    ///
    /// Parent Type: `Review`
    public struct ReviewAdded: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { StarWarsAPI.Objects.Review }
      public static var __selections: [Selection] { [
        .field("episode", GraphQLEnum<Episode>?.self),
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }

      /// The movie
      public var episode: GraphQLEnum<Episode>? { __data["episode"] }
      /// The number of stars this review gave, 1-5
      public var stars: Int { __data["stars"] }
      /// Comment about the movie
      public var commentary: String? { __data["commentary"] }
    }
  }
}
