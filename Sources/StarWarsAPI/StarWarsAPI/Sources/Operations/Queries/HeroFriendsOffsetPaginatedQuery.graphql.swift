// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsOffsetPaginatedQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsOffsetPaginated"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "abc818152f2617a753cd73aeee3f1d582f473eadbdb433ca4e0bdcc42c5b4745",
    definition: .init(
      #"""
      query HeroFriendsOffsetPaginated($limit: Int!, $offset: Int!) {
        hero {
          __typename
          id
          friendsPaginated(limit: $limit, offset: $offset) {
            __typename
            id
            name
          }
        }
      }
      """#
    ))

  public var limit: Int
  public var offset: Int

  public init(
    limit: Int,
    offset: Int
  ) {
    self.limit = limit
    self.offset = offset
  }

  public var __variables: Variables? { [
    "limit": limit,
    "offset": offset
  ] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    public init(
      hero: Hero? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "hero": hero._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.self)
        ]
      ))
    }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", StarWarsAPI.ID.self),
        .field("friendsPaginated", [FriendsPaginated?]?.self, arguments: [
          "limit": .variable("limit"),
          "offset": .variable("offset")
        ]),
      ] }

      /// The ID of the character
      public var id: StarWarsAPI.ID { __data["id"] }
      /// The friends of the character, with pagination.
      public var friendsPaginated: [FriendsPaginated?]? { __data["friendsPaginated"] }

      public init(
        __typename: String,
        id: StarWarsAPI.ID,
        friendsPaginated: [FriendsPaginated?]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "id": id,
            "friendsPaginated": friendsPaginated._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.Hero.self)
          ]
        ))
      }

      /// Hero.FriendsPaginated
      ///
      /// Parent Type: `Character`
      public struct FriendsPaginated: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", StarWarsAPI.ID.self),
          .field("name", String.self),
        ] }

        /// The ID of the character
        public var id: StarWarsAPI.ID { __data["id"] }
        /// The name of the character
        public var name: String { __data["name"] }

        public init(
          __typename: String,
          id: StarWarsAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.Hero.FriendsPaginated.self)
            ]
          ))
        }
      }
    }
  }
}
