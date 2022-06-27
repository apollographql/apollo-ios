// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAppearsInQuery: GraphQLQuery {
  public static let operationName: String = "HeroAppearsIn"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "22d772c0fc813281705e8f0a55fc70e71eeff6e98f3f9ef96cf67fb896914522",
    definition: .init(
      """
      query HeroAppearsIn {
        hero {
          __typename
          appearsIn
        }
      }
      """
    ))

  public init() {}

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
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
    }
  }
}