// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsUnconditionalAndConditionalInclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "65381a20574db4b458a0821328252deb0da1a107f9ab77c99fb2467e66a5f12d",
    definition: .init(
      #"""
      query HeroFriendsDetailsUnconditionalAndConditionalInclusion($includeFriendsDetails: Boolean!) {
        hero {
          __typename
          friends {
            __typename
            name
          }
          friends @include(if: $includeFriendsDetails) {
            __typename
            name
            ... on Droid {
              __typename
              primaryFunction
            }
          }
        }
      }
      """#
    ))

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var __variables: Variables? { ["includeFriendsDetails": includeFriendsDetails] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", Hero?.self),
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
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friends", [Friend?]?.self),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

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
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("name", String.self),
          .include(if: "includeFriendsDetails", .inlineFragment(IfIncludeFriendsDetails.self)),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }

        public var ifIncludeFriendsDetails: IfIncludeFriendsDetails? { _asInlineFragment(if: "includeFriendsDetails") }
        public var asDroid: AsDroid? { _asInlineFragment() }

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

        /// Hero.Friend.IfIncludeFriendsDetails
        ///
        /// Parent Type: `Character`
        public struct IfIncludeFriendsDetails: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public typealias RootEntityType = Hero.Friend
          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("name", String.self),
            .inlineFragment(AsDroid.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public var asDroid: AsDroid? { _asInlineFragment() }

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

          /// Hero.Friend.AsDroid
          ///
          /// Parent Type: `Droid`
          public struct AsDroid: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public typealias RootEntityType = Hero.Friend
            public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("primaryFunction", String?.self),
            ] }

            /// This droid's primary function
            public var primaryFunction: String? { __data["primaryFunction"] }
            /// The name of the character
            public var name: String { __data["name"] }

            public init(
              primaryFunction: String? = nil,
              name: String
            ) {
              let objectType = StarWarsAPI.Objects.Droid
              self.init(data: DataDict(
                objectType: objectType,
                data: [
                  "__typename": objectType.typename,
                  "primaryFunction": primaryFunction,
                  "name": name
              ]))
            }
          }
        }
        /// Hero.Friend.AsDroid
        ///
        /// Parent Type: `Droid`
        public struct AsDroid: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public typealias RootEntityType = Hero.Friend
          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }

          /// The name of the character
          public var name: String { __data["name"] }
          /// This droid's primary function
          public var primaryFunction: String? { __data["primaryFunction"] }

          public init(
            name: String,
            primaryFunction: String? = nil
          ) {
            let objectType = StarWarsAPI.Objects.Droid
            self.init(data: DataDict(
              objectType: objectType,
              data: [
                "__typename": objectType.typename,
                "name": name,
                "primaryFunction": primaryFunction
            ]))
          }
        }
      }
    }
  }
}
