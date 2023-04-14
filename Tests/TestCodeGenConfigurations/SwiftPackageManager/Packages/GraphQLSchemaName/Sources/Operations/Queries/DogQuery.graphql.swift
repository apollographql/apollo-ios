// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query DogQuery {
        allAnimals {
          __typename
          id
          skinCovering
          ... on Dog {
            __typename
            ...DogFragment
          }
        }
      }
      """#,
      fragments: [DogFragment.self]
    ))

  public init() {}

  public struct Data: GraphQLSchemaName.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: GraphQLSchemaName.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphQLSchemaName.ID.self),
        .field("skinCovering", GraphQLEnum<GraphQLSchemaName.SkinCovering>?.self),
        .inlineFragment(AsDog.self),
      ] }

      public var id: GraphQLSchemaName.ID { __data["id"] }
      public var skinCovering: GraphQLEnum<GraphQLSchemaName.SkinCovering>? { __data["skinCovering"] }

      public var asDog: AsDog? { _asInlineFragment() }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: GraphQLSchemaName.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = DogQuery.Data.AllAnimal
        public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Objects.Dog }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(DogFragment.self),
        ] }

        public var id: GraphQLSchemaName.ID { __data["id"] }
        public var skinCovering: GraphQLEnum<GraphQLSchemaName.SkinCovering>? { __data["skinCovering"] }
        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var dogFragment: DogFragment { _toFragment() }
        }
      }
    }
  }
}
