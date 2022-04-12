// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class SameHeroTwiceQuery: GraphQLQuery {
  public let operationName: String = "SameHeroTwice"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query SameHeroTwice {
        hero {
          name
        }
        r2: hero {
          appearsIn
        }
      }
      """
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self),
      .field("hero", alias: "r2", R2?.self),
    ] }

    public var hero: Hero? { data["hero"] }
    public var r2: R2? { data["r2"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      public var name: String { data["name"] }
    }

    /// R2
    public struct R2: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
    }
  }
}