// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class SearchQuery: GraphQLQuery {
  public let operationName: String = "Search"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query Search($term: String) {
        search(text: $term) {
          ... on Human {
            id
            name
          }
          ... on Droid {
            id
            name
          }
          ... on Starship {
            id
            name
          }
        }
      }
      """
    ))

  public var term: GraphQLNullable<String>

  public init(term: GraphQLNullable<String>) {
    self.term = term
  }

  public var variables: Variables? {
    ["term": term]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("search", [Search?]?.self, arguments: ["text": .variable("term")]),
    ] }

    public var search: [Search?]? { data["search"] }

    /// Search
    public struct Search: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Union(StarWarsAPI.SearchResult.self) }
      public static var selections: [Selection] { [
        .typeCase(AsHuman.self),
        .typeCase(AsDroid.self),
        .typeCase(AsStarship.self),
      ] }

      public var asHuman: AsHuman? { _asType() }
      public var asDroid: AsDroid? { _asType() }
      public var asStarship: AsStarship? { _asType() }

      /// Search.AsHuman
      public struct AsHuman: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { data["id"] }
        public var name: String { data["name"] }
      }

      /// Search.AsDroid
      public struct AsDroid: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { data["id"] }
        public var name: String { data["name"] }
      }

      /// Search.AsStarship
      public struct AsStarship: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Starship.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { data["id"] }
        public var name: String { data["name"] }
      }
    }
  }
}