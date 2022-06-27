// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroFriendsDetailsConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "9bdfeee789c1d22123402a9c3e3edefeb66799b3436289751be8f47905e3babd",
    definition: .init(
      """
      query HeroFriendsDetailsConditionalInclusion($includeFriendsDetails: Boolean!) {
        hero {
          __typename
          friends @include(if: $includeFriendsDetails) {
            __typename
            name
            ... on Droid {
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
        .include(if: "includeFriendsDetails", .field("friends", [Friend?]?.self)),
      ] }

      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
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
    }
  }
}