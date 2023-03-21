// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateAwesomeReviewMutation: GraphQLMutation {
  public static let operationName: String = "CreateAwesomeReview"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374",
    definition: .init(
      #"""
      mutation CreateAwesomeReview {
        createReview(episode: JEDI, review: {stars: 10, commentary: "This is awesome!"}) {
          __typename
          stars
          commentary
        }
      }
      """#
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createReview", CreateReview?.self, arguments: [
        "episode": "JEDI",
        "review": [
          "stars": 10,
          "commentary": "This is awesome!"
        ]
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
