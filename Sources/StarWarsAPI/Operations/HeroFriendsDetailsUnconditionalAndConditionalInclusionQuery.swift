// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  public let operationName: String = "HeroFriendsDetailsUnconditionalAndConditionalInclusion"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroFriendsDetailsUnconditionalAndConditionalInclusion($includeFriendsDetails: Boolean!) {
        hero {
          friends {
            name
          }
          friends @include(if: $includeFriendsDetails) {
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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
    ] }

    public var hero: Hero? { data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("friends", [Friend?]?.self),
      ] }

      public var friends: [Friend?]? { data["friends"] }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .field("name", String.self),
          .typeCase(AsDroid.self),
        ] }

        public var name: String { data["name"] }

        public var asDroid: AsDroid? { _asType() }

        /// Hero.Friend.AsDroid
        public struct AsDroid: StarWarsAPI.TypeCase {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
          public static var selections: [Selection] { [
            .field("primaryFunction", String?.self),
          ] }

          public var primaryFunction: String? { data["primaryFunction"] }
          public var name: String { data["name"] }
        }
      }
    }
  }
}