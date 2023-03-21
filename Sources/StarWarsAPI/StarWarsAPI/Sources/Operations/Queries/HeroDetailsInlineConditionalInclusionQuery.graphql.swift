// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroDetailsInlineConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsInlineConditionalInclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "3091d9d3f1d2374e2f835ce05d332e50b3fe61502d73213b9aa511f0f94f091c",
    definition: .init(
      #"""
      query HeroDetailsInlineConditionalInclusion($includeDetails: Boolean!) {
        hero {
          __typename
          ... @include(if: $includeDetails) {
            __typename
            name
            appearsIn
          }
        }
      }
      """#
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
        .include(if: "includeDetails", .inlineFragment(IfIncludeDetails.self)),
      ] }

      public var ifIncludeDetails: IfIncludeDetails? { _asInlineFragment(if: "includeDetails") }

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
        public static var __selections: [ApolloAPI.Selection] { [
          .field("name", String.self),
          .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }
        /// The movies this character appears in
        public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

        public init(
          __typename: String,
          name: String,
          appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?]
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              StarWarsAPI.Interfaces.Character
          ])
          self.init(_dataDict: DataDict(data: [
              "__typename": objectType.typename,
              "name": name,
              "appearsIn": appearsIn
            ]))
        }
      }
    }
  }
}
