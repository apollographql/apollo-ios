// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsDetailsConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsConditionalInclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "8cada231691ff2f5a0a07c54b7332114588f11b947795da345c5b054211fbcfd",
    definition: .init(
      #"""
      query HeroFriendsDetailsConditionalInclusion($includeFriendsDetails: Boolean!) {
        hero {
          __typename
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
          ObjectIdentifier(HeroFriendsDetailsConditionalInclusionQuery.Data.self)
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
        .include(if: "includeFriendsDetails", .field("friends", [Friend?]?.self)),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      public init(
        __typename: String,
        friends: [Friend?]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "friends": friends._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(HeroFriendsDetailsConditionalInclusionQuery.Data.Hero.self)
          ]
        ))
      }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
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
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(HeroFriendsDetailsConditionalInclusionQuery.Data.Hero.Friend.self)
            ]
          ))
        }

        /// Hero.Friend.AsDroid
        ///
        /// Parent Type: `Droid`
        public struct AsDroid: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = HeroFriendsDetailsConditionalInclusionQuery.Data.Hero.Friend
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
            self.init(_dataDict: DataDict(
              data: [
                "__typename": StarWarsAPI.Objects.Droid.typename,
                "primaryFunction": primaryFunction,
                "name": name,
              ],
              fulfilledFragments: [
                ObjectIdentifier(HeroFriendsDetailsConditionalInclusionQuery.Data.Hero.Friend.self),
                ObjectIdentifier(HeroFriendsDetailsConditionalInclusionQuery.Data.Hero.Friend.AsDroid.self)
              ]
            ))
          }
        }
      }
    }
  }
}
