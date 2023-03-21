// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNamesWithFragmentTwice"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "b5f4eca712a136f0d5d9f96203ef7d03cd119d8388f093f4b78ae124acb904cb",
    definition: .init(
      #"""
      query HeroAndFriendsNamesWithFragmentTwice($episode: Episode) {
        hero(episode: $episode) {
          __typename
          friends {
            __typename
            ...CharacterName
          }
          ... on Droid {
            __typename
            friends {
              __typename
              ...CharacterName
            }
          }
        }
      }
      """#,
      fragments: [CharacterName.self]
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var __variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    public init(
      hero: Hero? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "hero": hero._fieldData
      ]))
    }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friends", [Friend?]?.self),
        .inlineFragment(AsDroid.self),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      public init(
        __typename: String,
        friends: [Friend?]? = nil
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "friends": friends._fieldData
        ]))
      }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(CharacterName.self),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var characterName: CharacterName { _toFragment() }
        }

        public init(
          __typename: String,
          name: String
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              StarWarsAPI.Interfaces.Character
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "name": name
          ]))
        }
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }

        public init(
          friends: [Friend?]? = nil
        ) {
          let objectType = StarWarsAPI.Objects.Droid
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "friends": friends._fieldData
          ]))
        }

        /// Hero.AsDroid.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [ApolloAPI.Selection] { [
            .fragment(CharacterName.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var characterName: CharacterName { _toFragment() }
          }

          public init(
            __typename: String,
            name: String
          ) {
            let objectType = ApolloAPI.Object(
              typename: __typename,
              implementedInterfaces: [
                StarWarsAPI.Interfaces.Character
            ])
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "name": name
            ]))
          }
        }
      }
    }
  }
}
