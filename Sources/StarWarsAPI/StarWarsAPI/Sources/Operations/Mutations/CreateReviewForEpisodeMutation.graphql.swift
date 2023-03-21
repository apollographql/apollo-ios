// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateReviewForEpisodeMutation: GraphQLMutation {
  public static let operationName: String = "CreateReviewForEpisode"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "9bbf5b4074d0635fb19d17c621b7b04ebfb1920d468a94266819e149841e7d5d",
    definition: .init(
      #"""
      mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {
        createReview(episode: $episode, review: $review) {
          __typename
          stars
          commentary
        }
      }
      """#
    ))

  public var episode: GraphQLEnum<Episode>
  public var review: ReviewInput

  public init(
    episode: GraphQLEnum<Episode>,
    review: ReviewInput
  ) {
    self.episode = episode
    self.review = review
  }

  public var __variables: Variables? { [
    "episode": episode,
    "review": review
  ] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createReview", CreateReview?.self, arguments: [
        "episode": .variable("episode"),
        "review": .variable("review")
      ]),
    ] }

    public var createReview: CreateReview? { __data["createReview"] }

    public init(
      createReview: CreateReview? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Mutation
      self.init(_dataDict: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "createReview": createReview._fieldData
      ]))
    }

    /// CreateReview
    ///
    /// Parent Type: `Review`
    public struct CreateReview: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Review }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }

      /// The number of stars this review gave, 1-5
      public var stars: Int { __data["stars"] }
      /// Comment about the movie
      public var commentary: String? { __data["commentary"] }

      public init(
        stars: Int,
        commentary: String? = nil
      ) {
        let objectType = StarWarsAPI.Objects.Review
        self.init(_dataDict: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "stars": stars,
            "commentary": commentary
        ]))
      }
    }
  }
}
