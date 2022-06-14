// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class AllAnimalsLocalCacheMutation: GraphQLQuery {
  public static let operationName: String = "AllAnimalsLocalCacheMutation"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query AllAnimalsLocalCacheMutation {
        allAnimals {
          __typename
          species
          skinCovering
          ... on Bird {
            wingspan
          }
        }
      }
      """
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { data["allAnimals"] }

    /// AllAnimal
    public struct AllAnimal: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var species: String { data["species"] }
      public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }

      public var asBird: AsBird? { _asInlineFragment() }

      /// AllAnimal.AsBird
      public struct AsBird: AnimalKingdomAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
        public static var selections: [Selection] { [
          .field("wingspan", Float.self),
        ] }

        public var wingspan: Float { data["wingspan"] }
        public var species: String { data["species"] }
        public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
      }
    }
  }
}