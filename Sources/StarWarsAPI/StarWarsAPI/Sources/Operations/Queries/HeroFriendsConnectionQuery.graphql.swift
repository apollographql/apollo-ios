// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsConnectionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsConnection"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "762082ecae815f8a2bfec1d11d15c977dbb1f52cda2c58c66716bf220d7a6fbd",
    definition: .init(
      #"""
      query HeroFriendsConnection($id: ID!, $first: Int!, $after: ID) {
        character(id: $id) {
          __typename
          id
          name
          friendsConnection(first: $first, after: $after) {
            __typename
            friends {
              __typename
              id
              name
            }
            totalCount
            pageInfo {
              __typename
              hasNextPage
              endCursor
            }
          }
        }
      }
      """#
    ))

  public var id: ID
  public var first: Int
  public var after: GraphQLNullable<ID>

  public init(
    id: ID,
    first: Int,
    after: GraphQLNullable<ID>
  ) {
    self.id = id
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "id": id,
    "first": first,
    "after": after
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
          ObjectIdentifier(HeroFriendsConnectionQuery.Data.self)
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
        .field("friendsConnection", FriendsConnection.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// The ID of the character
      public var id: StarWarsAPI.ID { __data["id"] }
      /// The name of the character
      public var name: String { __data["name"] }
      /// The friends of the character exposed as a connection with edges
      public var friendsConnection: FriendsConnection { __data["friendsConnection"] }

      public init(
        __typename: String,
        id: StarWarsAPI.ID,
        name: String,
        friendsConnection: FriendsConnection
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "id": id,
            "name": name,
            "friendsConnection": friendsConnection._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(HeroFriendsConnectionQuery.Data.Character.self)
          ]
        ))
      }

      /// Character.FriendsConnection
      ///
      /// Parent Type: `FriendsConnection`
      public struct FriendsConnection: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.FriendsConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("friends", [Friend?]?.self),
          .field("totalCount", Int?.self),
          .field("pageInfo", PageInfo.self),
        ] }

        /// A list of the friends, as a convenience when edges are not needed.
        public var friends: [Friend?]? { __data["friends"] }
        /// The total number of friends
        public var totalCount: Int? { __data["totalCount"] }
        /// Information for paginating this connection
        public var pageInfo: PageInfo { __data["pageInfo"] }

        public init(
          friends: [Friend?]? = nil,
          totalCount: Int? = nil,
          pageInfo: PageInfo
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": StarWarsAPI.Objects.FriendsConnection.typename,
              "friends": friends._fieldData,
              "totalCount": totalCount,
              "pageInfo": pageInfo._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(HeroFriendsConnectionQuery.Data.Character.FriendsConnection.self)
            ]
          ))
        }

        /// Character.FriendsConnection.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
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
                ObjectIdentifier(HeroFriendsConnectionQuery.Data.Character.FriendsConnection.Friend.self)
              ]
            ))
          }
        }

        /// Character.FriendsConnection.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", StarWarsAPI.ID?.self),
          ] }

          public var hasNextPage: Bool { __data["hasNextPage"] }
          public var endCursor: StarWarsAPI.ID? { __data["endCursor"] }

          public init(
            hasNextPage: Bool,
            endCursor: StarWarsAPI.ID? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": StarWarsAPI.Objects.PageInfo.typename,
                "hasNextPage": hasNextPage,
                "endCursor": endCursor,
              ],
              fulfilledFragments: [
                ObjectIdentifier(HeroFriendsConnectionQuery.Data.Character.FriendsConnection.PageInfo.self)
              ]
            ))
          }
        }
      }
    }
  }
}
