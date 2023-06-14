// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TwoHeroesQuery: GraphQLQuery {
  public static let operationName: String = "TwoHeroes"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "b868fa9c48f19b8151c08c09f46831e3b9cd09f5c617d328647de785244b52bb",
    definition: .init(
      #"""
      query TwoHeroes {
        r2: hero {
          __typename
          name
        }
        luke: hero(episode: EMPIRE) {
          __typename
          name
        }
      }
      """#
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hero", alias: "r2", R2?.self),
      .field("hero", alias: "luke", Luke?.self, arguments: ["episode": "EMPIRE"]),
    ] }

    public var r2: R2? { __data["r2"] }
    public var luke: Luke? { __data["luke"] }

    public init(
      r2: R2? = nil,
      luke: Luke? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "r2": r2._fieldData,
          "luke": luke._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(TwoHeroesQuery.Data.self)
        ]
      ))
    }

    /// R2
    ///
    /// Parent Type: `Character`
    public struct R2: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

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
            ObjectIdentifier(TwoHeroesQuery.Data.R2.self)
          ]
        ))
      }
    }

    /// Luke
    ///
    /// Parent Type: `Character`
    public struct Luke: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

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
            ObjectIdentifier(TwoHeroesQuery.Data.Luke.self)
          ]
        ))
      }
    }
  }
}
