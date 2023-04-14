// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public static let operationName: String = "HeroParentTypeDependentField"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "39eb41b5a9477c36fa529c23d6f0de6ebcc0312daf5bdcfe208d5baec752dc5b",
    definition: .init(
      #"""
      query HeroParentTypeDependentField($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          ... on Human {
            __typename
            friends {
              __typename
              name
              ... on Human {
                __typename
                height(unit: FOOT)
              }
            }
          }
          ... on Droid {
            __typename
            friends {
              __typename
              name
              ... on Human {
                __typename
                height(unit: METER)
              }
            }
          }
        }
      }
      """#
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
      self.init(_dataDict: DataDict(data: [
        "__typename": StarWarsAPI.Objects.Query.typename,
        "hero": hero._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
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
        .field("__typename", String.self),
        .field("name", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      public init(
        __typename: String,
        name: String
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "name": name,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }

      /// Hero.AsHuman
      ///
      /// Parent Type: `Human`
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = HeroParentTypeDependentFieldQuery.Data.Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        /// This human's friends, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }
        /// The name of the character
        public var name: String { __data["name"] }

        public init(
          friends: [Friend?]? = nil,
          name: String
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": StarWarsAPI.Objects.Human.typename,
            "friends": friends._fieldData,
            "name": name,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(Hero.self)
            ])
          ]))
        }

        /// Hero.AsHuman.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          public init(
            __typename: String,
            name: String
          ) {
            self.init(_dataDict: DataDict(data: [
              "__typename": __typename,
              "name": name,
              "__fulfilled": Set([
                ObjectIdentifier(Self.self)
              ])
            ]))
          }

          /// Hero.AsHuman.Friend.AsHuman
          ///
          /// Parent Type: `Human`
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = HeroParentTypeDependentFieldQuery.Data.Hero.AsHuman.Friend
            public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("height", Double?.self, arguments: ["unit": "FOOT"]),
            ] }

            /// Height in the preferred unit, default is meters
            public var height: Double? { __data["height"] }
            /// The name of the character
            public var name: String { __data["name"] }

            public init(
              height: Double? = nil,
              name: String
            ) {
              self.init(_dataDict: DataDict(data: [
                "__typename": StarWarsAPI.Objects.Human.typename,
                "height": height,
                "name": name,
                "__fulfilled": Set([
                  ObjectIdentifier(Self.self),
                  ObjectIdentifier(Hero.AsHuman.Friend.self)
                ])
              ]))
            }
          }
        }
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = HeroParentTypeDependentFieldQuery.Data.Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }
        /// The name of the character
        public var name: String { __data["name"] }

        public init(
          friends: [Friend?]? = nil,
          name: String
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": StarWarsAPI.Objects.Droid.typename,
            "friends": friends._fieldData,
            "name": name,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(Hero.self)
            ])
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
            .field("__typename", String.self),
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          public init(
            __typename: String,
            name: String
          ) {
            self.init(_dataDict: DataDict(data: [
              "__typename": __typename,
              "name": name,
              "__fulfilled": Set([
                ObjectIdentifier(Self.self)
              ])
            ]))
          }

          /// Hero.AsDroid.Friend.AsHuman
          ///
          /// Parent Type: `Human`
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = HeroParentTypeDependentFieldQuery.Data.Hero.AsDroid.Friend
            public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("height", Double?.self, arguments: ["unit": "METER"]),
            ] }

            /// Height in the preferred unit, default is meters
            public var height: Double? { __data["height"] }
            /// The name of the character
            public var name: String { __data["name"] }

            public init(
              height: Double? = nil,
              name: String
            ) {
              self.init(_dataDict: DataDict(data: [
                "__typename": StarWarsAPI.Objects.Human.typename,
                "height": height,
                "name": name,
                "__fulfilled": Set([
                  ObjectIdentifier(Self.self),
                  ObjectIdentifier(Hero.AsDroid.Friend.self)
                ])
              ]))
            }
          }
        }
      }
    }
  }
}
