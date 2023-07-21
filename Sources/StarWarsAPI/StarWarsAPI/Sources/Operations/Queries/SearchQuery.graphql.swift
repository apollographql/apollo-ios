// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchQuery: GraphQLQuery {
  public static let operationName: String = "Search"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    operationIdentifier: "29ecc9c7acac3eab2585d305aed9f8257b448bc7ea57341a135d1fa476973ecb",
    definition: .init(
      #"query Search($term: String) { search(text: $term) { __typename ... on Human { __typename id name } ... on Droid { __typename id name } ... on Starship { __typename id name } } }"#
    ))

  public var term: GraphQLNullable<String>

  public init(term: GraphQLNullable<String>) {
    self.term = term
  }

  public var __variables: Variables? { ["term": term] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("search", [Search?]?.self, arguments: ["text": .variable("term")]),
    ] }

    public var search: [Search?]? { __data["search"] }

    public init(
      search: [Search?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Query.typename,
          "search": search._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SearchQuery.Data.self)
        ]
      ))
    }

    /// Search
    ///
    /// Parent Type: `SearchResult`
    public struct Search: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Unions.SearchResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
        .inlineFragment(AsStarship.self),
      ] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }
      public var asStarship: AsStarship? { _asInlineFragment() }

      public init(
        __typename: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SearchQuery.Data.Search.self)
          ]
        ))
      }

      /// Search.AsHuman
      ///
      /// Parent Type: `Human`
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SearchQuery.Data.Search
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", StarWarsAPI.ID.self),
          .field("name", String.self),
        ] }

        /// The ID of the human
        public var id: StarWarsAPI.ID { __data["id"] }
        /// What this human calls themselves
        public var name: String { __data["name"] }

        public init(
          id: StarWarsAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": StarWarsAPI.Objects.Human.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(SearchQuery.Data.Search.self),
              ObjectIdentifier(SearchQuery.Data.Search.AsHuman.self)
            ]
          ))
        }
      }

      /// Search.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SearchQuery.Data.Search
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", StarWarsAPI.ID.self),
          .field("name", String.self),
        ] }

        /// The ID of the droid
        public var id: StarWarsAPI.ID { __data["id"] }
        /// What others call this droid
        public var name: String { __data["name"] }

        public init(
          id: StarWarsAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": StarWarsAPI.Objects.Droid.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(SearchQuery.Data.Search.self),
              ObjectIdentifier(SearchQuery.Data.Search.AsDroid.self)
            ]
          ))
        }
      }

      /// Search.AsStarship
      ///
      /// Parent Type: `Starship`
      public struct AsStarship: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SearchQuery.Data.Search
        public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Starship }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", StarWarsAPI.ID.self),
          .field("name", String.self),
        ] }

        /// The ID of the starship
        public var id: StarWarsAPI.ID { __data["id"] }
        /// The name of the starship
        public var name: String { __data["name"] }

        public init(
          id: StarWarsAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": StarWarsAPI.Objects.Starship.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(SearchQuery.Data.Search.self),
              ObjectIdentifier(SearchQuery.Data.Search.AsStarship.self)
            ]
          ))
        }
      }
    }
  }
}
