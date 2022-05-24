// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class CreateAwesomeReviewMutation: GraphQLMutation {
  public static let operationName: String = "CreateAwesomeReview"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation CreateAwesomeReview {
        createReview(episode: JEDI, review: {stars: 10, commentary: "This is awesome!"}) {
          __typename
          stars
          commentary
        }
      }
      """
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Mutation.self) }
    public static var selections: [Selection] { [
      .field("createReview", CreateReview?.self, arguments: [
        "episode": "JEDI",
        "review": [
          "stars": 10,
          "commentary": "This is awesome!"
        ]
      ]),
    ] }

    public var createReview: CreateReview? { data["createReview"] }

    /// CreateReview
    public struct CreateReview: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Review.self) }
      public static var selections: [Selection] { [
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }

      public var stars: Int { data["stars"] }
      public var commentary: String? { data["commentary"] }
    }
  }
}