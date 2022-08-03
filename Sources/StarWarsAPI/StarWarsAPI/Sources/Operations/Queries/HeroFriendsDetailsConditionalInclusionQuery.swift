// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroFriendsDetailsConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsDetailsConditionalInclusion"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "8cada231691ff2f5a0a07c54b7332114588f11b947795da345c5b054211fbcfd",
    definition: .init(
      """
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

    public static var __parentType: ParentType { StarWarsAPI.Objects.Query }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
      public static var selections: [Selection] { [
        .include(if: "includeFriendsDetails", .field("friends", [Friend?]?.self)),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
        public static var selections: [Selection] { [
          .field("name", String.self),
          .inlineFragment(AsDroid.self),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }

        public var asDroid: AsDroid? { _asInlineFragment() }

        /// Hero.Friend.AsDroid
        ///
        /// Parent Type: `Droid`
        public struct AsDroid: StarWarsAPI.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { StarWarsAPI.Objects.Droid }
          public static var selections: [Selection] { [
            .field("primaryFunction", String?.self),
          ] }

          /// This droid's primary function
          public var primaryFunction: String? { __data["primaryFunction"] }
          /// The name of the character
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
