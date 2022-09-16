// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class CreateReviewWithNullFieldMutation: GraphQLMutation {
  public static let operationName: String = "CreateReviewWithNullField"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "a9600d176cd7e4671b8689f1d01fe79ea896932bfafb8a925af673f0e4111828",
    definition: .init(
      """
      mutation CreateReviewWithNullField {
        createReview(episode: JEDI, review: {stars: 10, commentary: null}) {
          __typename
          stars
          commentary
        }
      }
      """
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("createReview", CreateReview?.self, arguments: [
        "episode": "JEDI",
        "review": [
          "stars": 10,
          "commentary": .null
        ]
      ]),
    ] }

    public var createReview: CreateReview? { __data["createReview"] }

    /// CreateReview
    ///
    /// Parent Type: `Review`
    public struct CreateReview: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { StarWarsAPI.Objects.Review }
      public static var __selections: [Selection] { [
        .field("stars", Int.self),
        .field("commentary", String?.self),
      ] }

      /// The number of stars this review gave, 1-5
      public var stars: Int { __data["stars"] }
      /// Comment about the movie
      public var commentary: String? { __data["commentary"] }
    }
  }
}
