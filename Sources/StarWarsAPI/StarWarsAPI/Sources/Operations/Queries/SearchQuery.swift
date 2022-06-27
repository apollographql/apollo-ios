// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class SearchQuery: GraphQLQuery {
  public static let operationName: String = "Search"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "73536da2eec4d83e6e1003e674cb2299d9da2798f7bd310e57339a6bcd713b77",
    definition: .init(
      """
      query Search($term: String) {
        search(text: $term) {
          __typename
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
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("search", [Search?]?.self, arguments: ["text": .variable("term")]),
    ] }

    public var search: [Search?]? { __data["search"] }

    /// Search
    public struct Search: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Union(StarWarsAPI.SearchResult.self) }
      public static var selections: [Selection] { [
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
        .inlineFragment(AsStarship.self),
      ] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }
      public var asStarship: AsStarship? { _asInlineFragment() }

      /// Search.AsHuman
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { __data["id"] }
        public var name: String { __data["name"] }
      }

      /// Search.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { __data["id"] }
        public var name: String { __data["name"] }
      }

      /// Search.AsStarship
      public struct AsStarship: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Starship.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { __data["id"] }
        public var name: String { __data["name"] }
      }
    }
  }
}