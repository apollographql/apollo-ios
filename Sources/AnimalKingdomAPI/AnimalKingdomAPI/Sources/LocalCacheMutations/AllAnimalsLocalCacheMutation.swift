// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class AllAnimalsLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: AnimalKingdomAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Objects.Query) }
    public static var selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] {
      get { __data["allAnimals"] }
      set { __data["allAnimals"] = newValue }
    }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: AnimalKingdomAPI.MutableSelectionSet {
      public var __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Interfaces.Animal) }
      public static var selections: [Selection] { [
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var species: String {
        get { __data["species"] }
        set { __data["species"] = newValue }
      }
      public var skinCovering: GraphQLEnum<SkinCovering>? {
        get { __data["skinCovering"] }
        set { __data["skinCovering"] = newValue }
      }

      public var asBird: AsBird? {
        get { _asInlineFragment() }
        set { if let newData = newValue?.__data._data { __data._data = newData }}
      }

      /// AllAnimal.AsBird
      ///
      /// Parent Type: `Bird`
      public struct AsBird: AnimalKingdomAPI.MutableInlineFragment {
        public var __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Objects.Bird) }
        public static var selections: [Selection] { [
          .field("wingspan", Double.self),
        ] }

        public var wingspan: Double {
          get { __data["wingspan"] }
          set { __data["wingspan"] = newValue }
        }
        public var species: String {
          get { __data["species"] }
          set { __data["species"] = newValue }
        }
        public var skinCovering: GraphQLEnum<SkinCovering>? {
          get { __data["skinCovering"] }
          set { __data["skinCovering"] = newValue }
        }
      }
    }
  }
}
