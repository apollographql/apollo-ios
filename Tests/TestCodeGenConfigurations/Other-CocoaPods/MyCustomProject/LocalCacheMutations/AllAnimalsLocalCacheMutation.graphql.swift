// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class AllAnimalsLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: MyCustomProject.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] {
      get { __data["allAnimals"] }
      set { __data["allAnimals"] = newValue }
    }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MyCustomProject.MutableSelectionSet {
      public var __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyCustomProject.Interfaces.Animal }
      public static var __selections: [Selection] { [
        .field("hash", String?.self),
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var hash: String? {
        get { __data["hash"] }
        set { __data["hash"] = newValue }
      }
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
      public struct AsBird: MyCustomProject.MutableInlineFragment {
        public var __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyCustomProject.Objects.Bird }
        public static var __selections: [Selection] { [
          .field("wingspan", Double.self),
        ] }

        public var wingspan: Double {
          get { __data["wingspan"] }
          set { __data["wingspan"] = newValue }
        }
        public var hash: String? {
          get { __data["hash"] }
          set { __data["hash"] = newValue }
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
