// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsUnconditionalAndConditionalInclusion"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
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
          ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.self)
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
        .field("friends", [Friend?]?.self),
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
            ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.self)
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
          .include(if: "includeFriendsDetails", .inlineFragment(IfIncludeFriendsDetails.self)),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }

        public var ifIncludeFriendsDetails: IfIncludeFriendsDetails? { _asInlineFragment() }
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
              ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.self)
            ]
          ))
        }

        /// Hero.Friend.IfIncludeFriendsDetails
        ///
        /// Parent Type: `Character`
        public struct IfIncludeFriendsDetails: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend
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
            self.init(_dataDict: DataDict(
              data: [
                "__typename": __typename,
                "name": name,
              ],
              fulfilledFragments: [
                ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.self),
                ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.IfIncludeFriendsDetails.self)
              ]
            ))
          }

          /// Hero.Friend.AsDroid
          ///
          /// Parent Type: `Droid`
          public struct AsDroid: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend
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
                  ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.self),
                  ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.AsDroid.self)
                ]
              ))
            }
          }
        }
        /// Hero.Friend.AsDroid
        ///
        /// Parent Type: `Droid`
        public struct AsDroid: StarWarsAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend
          public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.self,
            HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.AsDroid.self
          ] }

          /// The name of the character
          public var name: String { __data["name"] }
          /// This droid's primary function
          public var primaryFunction: String? { __data["primaryFunction"] }

          public init(
            name: String,
            primaryFunction: String? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": StarWarsAPI.Objects.Droid.typename,
                "name": name,
                "primaryFunction": primaryFunction,
              ],
              fulfilledFragments: [
                ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.self),
                ObjectIdentifier(HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery.Data.Hero.Friend.AsDroid.self)
              ]
            ))
          }
        }
      }
    }
  }
}
