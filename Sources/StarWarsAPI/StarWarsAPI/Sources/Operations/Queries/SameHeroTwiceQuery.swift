// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class SameHeroTwiceQuery: GraphQLQuery {
  public static let operationName: String = "SameHeroTwice"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query SameHeroTwice {
        hero {
          __typename
          name
        }
        r2: hero {
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
      .field("hero", alias: "r2", R2?.self),
    ] }

    public var hero: Hero? { __data["hero"] }
    public var r2: R2? { __data["r2"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      public var name: String { __data["name"] }
    }

    /// R2
    public struct R2: StarWarsAPI.SelectionSet {
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