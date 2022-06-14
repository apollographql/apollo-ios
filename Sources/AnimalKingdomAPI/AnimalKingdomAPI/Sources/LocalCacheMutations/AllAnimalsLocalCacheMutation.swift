// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class AllAnimalsLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: AnimalKingdomAPI.MutableSelectionSet {
    public var data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] {
      get { data["allAnimals"] }
      set { data["allAnimals"] = newValue }
    }

    /// AllAnimal
    public struct AllAnimal: AnimalKingdomAPI.MutableSelectionSet {
      public var data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var species: String {
        get { data["species"] }
        set { data["species"] = newValue }
      }
      public var skinCovering: GraphQLEnum<SkinCovering>? {
        get { data["skinCovering"] }
        set { data["skinCovering"] = newValue }
      }

      public var asBird: AsBird? {
        get { _asInlineFragment() }
        set { if let newData = newValue?.data._data { data._data = newData }}
      }

      /// AllAnimal.AsBird
      public struct AsBird: AnimalKingdomAPI.MutableInlineFragment {
        public var data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
        public static var selections: [Selection] { [
          .field("wingspan", Float.self),
        ] }

        public var wingspan: Float {
          get { data["wingspan"] }
          set { data["wingspan"] = newValue }
        }
        public var species: String {
          get { data["species"] }
          set { data["species"] = newValue }
        }
        public var skinCovering: GraphQLEnum<SkinCovering>? {
          get { data["skinCovering"] }
          set { data["skinCovering"] = newValue }
        }
      }
    }
  }
}