// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsConnectionLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

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

  public var __variables: GraphQLOperation.Variables? { [
    "id": id,
    "first": first,
    "after": after
  ] }

  public struct Data: StarWarsAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("character", Character?.self, arguments: ["id": .variable("id")]),
    ] }

    public var character: Character? {
      get { __data["character"] }
      set { __data["character"] = newValue }
    }

    public init(
      character: Character? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "character": character._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(HeroFriendsConnectionLocalCacheMutation.Data.self)
        ]
      ))
    }

    /// Character
    ///
    /// Parent Type: `Character`
    public struct Character: StarWarsAPI.MutableSelectionSet {
      public var __data: DataDict
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
      public var id: StarWarsAPI.ID {
        get { __data["id"] }
        set { __data["id"] = newValue }
      }
      /// The name of the character
      public var name: String {
        get { __data["name"] }
        set { __data["name"] = newValue }
      }
      /// The friends of the character exposed as a connection with edges
      public var friendsConnection: FriendsConnection {
        get { __data["friendsConnection"] }
        set { __data["friendsConnection"] = newValue }
      }

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
            ObjectIdentifier(HeroFriendsConnectionLocalCacheMutation.Data.Character.self)
          ]
        ))
      }

      /// Character.FriendsConnection
      ///
      /// Parent Type: `FriendsConnection`
      public struct FriendsConnection: StarWarsAPI.MutableSelectionSet {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.FriendsConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("friends", [Friend?]?.self),
          .field("totalCount", Int?.self),
          .field("pageInfo", PageInfo.self),
        ] }

        /// A list of the friends, as a convenience when edges are not needed.
        public var friends: [Friend?]? {
          get { __data["friends"] }
          set { __data["friends"] = newValue }
        }
        /// The total number of friends
        public var totalCount: Int? {
          get { __data["totalCount"] }
          set { __data["totalCount"] = newValue }
        }
        /// Information for paginating this connection
        public var pageInfo: PageInfo {
          get { __data["pageInfo"] }
          set { __data["pageInfo"] = newValue }
        }

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
              ObjectIdentifier(HeroFriendsConnectionLocalCacheMutation.Data.Character.FriendsConnection.self)
            ]
          ))
        }

        /// Character.FriendsConnection.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.MutableSelectionSet {
          public var __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", StarWarsAPI.ID.self),
            .field("name", String.self),
          ] }

          /// The ID of the character
          public var id: StarWarsAPI.ID {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }
          /// The name of the character
          public var name: String {
            get { __data["name"] }
            set { __data["name"] = newValue }
          }

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
                ObjectIdentifier(HeroFriendsConnectionLocalCacheMutation.Data.Character.FriendsConnection.Friend.self)
              ]
            ))
          }
        }

        /// Character.FriendsConnection.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: StarWarsAPI.MutableSelectionSet {
          public var __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", StarWarsAPI.ID?.self),
          ] }

          public var hasNextPage: Bool {
            get { __data["hasNextPage"] }
            set { __data["hasNextPage"] = newValue }
          }
          public var endCursor: StarWarsAPI.ID? {
            get { __data["endCursor"] }
            set { __data["endCursor"] = newValue }
          }

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
                ObjectIdentifier(HeroFriendsConnectionLocalCacheMutation.Data.Character.FriendsConnection.PageInfo.self)
              ]
            ))
          }
        }
      }
    }
  }
}
