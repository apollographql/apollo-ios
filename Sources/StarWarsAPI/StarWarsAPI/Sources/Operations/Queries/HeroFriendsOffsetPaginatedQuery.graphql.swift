// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsOffsetPaginatedQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsOffsetPaginated"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "493e2240900e091aa81c9aafd30454e25d14f116056981a1e18e3042e92dcdd0",
    definition: .init(
      #"""
      query HeroFriendsOffsetPaginated($id: ID!, $limit: Int!, $offset: Int!) {
        character(id: $id) {
          __typename
          id
          name
          friendsPaginated(limit: $limit, offset: $offset) {
            __typename
            id
            name
          }
        }
      }
      """#
    ))

  public var id: ID
  public var limit: Int
  public var offset: Int

  public init(
    id: ID,
    limit: Int,
    offset: Int
  ) {
    self.id = id
    self.limit = limit
    self.offset = offset
  }

  public var __variables: Variables? { [
    "id": id,
    "limit": limit,
    "offset": offset
  ] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("character", Character?.self, arguments: ["id": .variable("id")]),
    ] }

    public var character: Character? { __data["character"] }

    public init(
      character: Character? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "character": character._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.self)
        ]
      ))
    }

    /// Character
    ///
    /// Parent Type: `Character`
    public struct Character: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", StarWarsAPI.ID.self),
        .field("name", String.self),
        .field("friendsPaginated", [FriendsPaginated?]?.self, arguments: [
          "limit": .variable("limit"),
          "offset": .variable("offset")
        ]),
      ] }

      /// The ID of the character
      public var id: StarWarsAPI.ID { __data["id"] }
      /// The name of the character
      public var name: String { __data["name"] }
      /// The friends of the character, with pagination.
      public var friendsPaginated: [FriendsPaginated?]? { __data["friendsPaginated"] }

      public init(
        __typename: String,
        id: StarWarsAPI.ID,
        name: String,
        friendsPaginated: [FriendsPaginated?]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "id": id,
            "name": name,
            "friendsPaginated": friendsPaginated._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.Character.self)
          ]
        ))
      }

      /// Character.FriendsPaginated
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
              ObjectIdentifier(HeroFriendsOffsetPaginatedQuery.Data.Character.FriendsPaginated.self)
            ]
          ))
        }
      }
    }
  }
}
