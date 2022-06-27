// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsUnconditionalAndConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "65381a20574db4b458a0821328252deb0da1a107f9ab77c99fb2467e66a5f12d",
    definition: .init(
      """
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
      """
    ))

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var variables: Variables? {
    ["includeFriendsDetails": includeFriendsDetails]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("friends", [Friend?]?.self),
      ] }

      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .field("name", String.self),
          .include(if: "includeFriendsDetails", .inlineFragment(IfIncludeFriendsDetails.self)),
        ] }

        public var name: String { __data["name"] }

        public var ifIncludeFriendsDetails: IfIncludeFriendsDetails? { _asInlineFragment(if: "includeFriendsDetails") }
        public var asDroid: AsDroid? { _asInlineFragment() }

        /// Hero.Friend.IfIncludeFriendsDetails
        public struct IfIncludeFriendsDetails: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .field("name", String.self),
            .inlineFragment(AsDroid.self),
          ] }

          public var name: String { __data["name"] }

          public var asDroid: AsDroid? { _asInlineFragment() }

          /// Hero.Friend.AsDroid
          public struct AsDroid: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
            public static var selections: [Selection] { [
              .field("primaryFunction", String?.self),
            ] }

            public var primaryFunction: String? { __data["primaryFunction"] }
            public var name: String { __data["name"] }
          }
        }
        /// Hero.Friend.AsDroid
        public struct AsDroid: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }

          public var name: String { __data["name"] }
          public var primaryFunction: String? { __data["primaryFunction"] }
        }
      }
    }
  }
}