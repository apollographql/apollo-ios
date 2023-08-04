// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalInclusion"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "dd8e5df9634bb4fb6455e4aaddd2941c5abf785b7d28cda959aba65157e950c6",
    definition: .init(
      #"query HeroNameConditionalInclusion($includeName: Boolean!) { hero { __typename name @include(if: $includeName) } }"#
    ))

  public var includeName: Bool

  public init(includeName: Bool) {
    self.includeName = includeName
  }

  public var __variables: Variables? { ["includeName": includeName] }

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
          ObjectIdentifier(HeroNameConditionalInclusionQuery.Data.self)
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
        .include(if: "includeName", .field("name", String.self)),
      ] }

      /// The name of the character
      public var name: String? { __data["name"] }

      public init(
        __typename: String,
        name: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "name": name,
          ],
          fulfilledFragments: [
            ObjectIdentifier(HeroNameConditionalInclusionQuery.Data.Hero.self)
          ]
        ))
      }
    }
  }
}
