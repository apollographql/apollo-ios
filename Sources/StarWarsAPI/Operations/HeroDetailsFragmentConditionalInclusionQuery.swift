// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  public let operationName: String = "HeroDetailsFragmentConditionalInclusion"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {
        hero {
          ...HeroDetails @include(if: $includeDetails)
        }
      }
      """,
      fragments: [HeroDetails.self]
    ))

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: Variables? {
    ["includeDetails": includeDetails]
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
        .fragment(HeroDetails.self),
      ] }

      public var name: String { data["name"] }

      public var asHuman: AsHuman? { _asType() }
      public var asDroid: AsDroid? { _asType() }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var heroDetails: HeroDetails { _toFragment() }
      }

      /// Hero.AsHuman
      public struct AsHuman: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }

        public var name: String { data["name"] }
        public var height: Float? { data["height"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heroDetails: HeroDetails { _toFragment() }
        }
      }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }

        public var name: String { data["name"] }
        public var primaryFunction: String? { data["primaryFunction"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heroDetails: HeroDetails { _toFragment() }
        }
      }
    }
  }
}