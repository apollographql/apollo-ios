// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReviewAddedSubscription: GraphQLSubscription {
  public static let operationName: String = "ReviewAdded"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "2a05903b49a3b665eeb8f7a24240623aff77f1555e006f11bca604540c7cdba8",
    definition: .init(
      #"subscription ReviewAdded($episode: Episode) { reviewAdded(episode: $episode) { __typename episode stars commentary } }"#
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var __variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Subscription }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("reviewAdded", ReviewAdded?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var reviewAdded: ReviewAdded? { __data["reviewAdded"] }

    public init(
      reviewAdded: ReviewAdded? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Subscription.typename,
          "reviewAdded": reviewAdded._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ReviewAddedSubscription.Data.self)
        ]
      ))
    }

    /// ReviewAdded
    ///
    /// Parent Type: `Review`
    public struct ReviewAdded: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Review }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("episode", GraphQLEnum<StarWarsAPI.Episode>?.self),
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }

      /// The movie
      public var episode: GraphQLEnum<StarWarsAPI.Episode>? { __data["episode"] }
      /// The number of stars this review gave, 1-5
      public var stars: Int { __data["stars"] }
      /// Comment about the movie
      public var commentary: String? { __data["commentary"] }

      public init(
        episode: GraphQLEnum<StarWarsAPI.Episode>? = nil,
        stars: Int,
        commentary: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": StarWarsAPI.Objects.Review.typename,
            "episode": episode,
            "stars": stars,
            "commentary": commentary,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ReviewAddedSubscription.Data.ReviewAdded.self)
          ]
        ))
      }
    }
  }
}
