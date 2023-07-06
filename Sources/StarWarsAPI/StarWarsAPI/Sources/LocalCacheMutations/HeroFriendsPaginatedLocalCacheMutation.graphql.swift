// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsPaginatedLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

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

  public var __variables: GraphQLOperation.Variables? { [
    "id": id,
    "limit": limit,
    "offset": offset
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
          ObjectIdentifier(HeroFriendsPaginatedLocalCacheMutation.Data.self)
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
        .field("friendsPaginated", [FriendsPaginated?]?.self, arguments: [
          "limit": .variable("limit"),
          "offset": .variable("offset")
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
      /// The friends of the character, with pagination.
      public var friendsPaginated: [FriendsPaginated?]? {
        get { __data["friendsPaginated"] }
        set { __data["friendsPaginated"] = newValue }
      }

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
            ObjectIdentifier(HeroFriendsPaginatedLocalCacheMutation.Data.Character.self)
          ]
        ))
      }

      /// Character.FriendsPaginated
      ///
      /// Parent Type: `Character`
      public struct FriendsPaginated: StarWarsAPI.MutableSelectionSet {
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
              ObjectIdentifier(HeroFriendsPaginatedLocalCacheMutation.Data.Character.FriendsPaginated.self)
            ]
          ))
        }
      }
    }
  }
}
