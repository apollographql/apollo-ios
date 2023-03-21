// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsFragmentConditionalInclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "b0fa7927ff93b4a579c3460fb04d093072d34c8018e41197c7e080aeeec5e19b",
    definition: .init(
      #"""
      query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {
        hero {
          __typename
          ...HeroDetails @include(if: $includeDetails)
        }
      }
      """#,
      fragments: [HeroDetails.self]
    ))

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var __variables: Variables? { ["includeDetails": includeDetails] }

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
      let objectType = StarWarsAPI.Objects.Query
      self.init(_dataDict: DataDict(data: [
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
        .include(if: "includeDetails", .fragment(HeroDetails.self)),
      ] }

      public var ifIncludeDetails: IfIncludeDetails? { _asInlineFragment(if: "includeDetails") }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var heroDetails: HeroDetails? { _toFragment(if: "includeDetails") }
      }

      public init(
        __typename: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(_dataDict: DataDict(data: [
            "__typename": objectType.typename,
          ]))
      }

      /// Hero.IfIncludeDetails
      ///
      /// Parent Type: `Character`
      public struct IfIncludeDetails: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = Hero
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }

        /// The name of the character
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var heroDetails: HeroDetails { _toFragment() }
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
          self.init(_dataDict: DataDict(data: [
              "__typename": objectType.typename,
              "name": name
            ]))
        }
      }
    }
  }
}
