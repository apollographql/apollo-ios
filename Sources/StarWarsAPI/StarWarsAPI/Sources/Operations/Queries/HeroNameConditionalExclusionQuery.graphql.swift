// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameConditionalExclusion"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "3dd42259adf2d0598e89e0279bee2c128a7913f02b1da6aa43f3b5def6a8a1f8",
    definition: .init(
      #"""
      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          __typename
          name @skip(if: $skipName)
        }
      }
      """#
    ))

  public var skipName: Bool

  public init(skipName: Bool) {
    self.skipName = skipName
  }

  public var __variables: Variables? { ["skipName": skipName] }

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
      self.init(data: DataDict(
        objectType: objectType,
        data: [
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
        .include(if: !"skipName", .field("name", String.self)),
      ] }

      /// The name of the character
      public var name: String? { __data["name"] }

      public init(
        __typename: String,
        name: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "name": name
        ]))
      }
    }
  }
}
