// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class AllAnimalsLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: MyCustomProject.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Apollo.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] {
      get { __data["allAnimals"] }
      set { __data["allAnimals"] = newValue }
    }

    public init(
      allAnimals: [AllAnimal]
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": MyCustomProject.Objects.Query.typename,
        "allAnimals": allAnimals._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MyCustomProject.MutableSelectionSet {
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Animal }
      public static var __selections: [Apollo.Selection] { [
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<MyCustomProject.SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var species: String {
        get { __data["species"] }
        set { __data["species"] = newValue }
      }
      public var skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? {
        get { __data["skinCovering"] }
        set { __data["skinCovering"] = newValue }
      }

      public var asBird: AsBird? {
        get { _asInlineFragment() }
        set { if let newData = newValue?.__data._data { __data._data = newData }}
      }

      public init(
        __typename: String,
        species: String,
        skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? = nil
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "species": species,
          "skinCovering": skinCovering,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }

      /// AllAnimal.AsBird
      ///
      /// Parent Type: `Bird`
      public struct AsBird: MyCustomProject.MutableInlineFragment {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Bird }
        public static var __selections: [Apollo.Selection] { [
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
        public var skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? {
          get { __data["skinCovering"] }
          set { __data["skinCovering"] = newValue }
        }

        public init(
          wingspan: Double,
          species: String,
          skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? = nil
        ) {
          self.init(_dataDict: DataDict(data: [
            "__typename": MyCustomProject.Objects.Bird.typename,
            "wingspan": wingspan,
            "species": species,
            "skinCovering": skinCovering,
            "__fulfilled": Set([
              ObjectIdentifier(Self.self),
              ObjectIdentifier(AllAnimal.self)
            ])
          ]))
        }
      }
    }
  }
}
