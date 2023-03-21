// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

class AllAnimalsLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: MySchemaModule.MutableSelectionSet {
    public var __data: DataDict
    public init(_data: DataDict) { __data = _data }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] {
      get { __data["allAnimals"] }
      set { __data["allAnimals"] = newValue }
    }

    public init(
      allAnimals: [AllAnimal]
    ) {
      let objectType = MySchemaModule.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "allAnimals": allAnimals._fieldData
      ]))
    }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MySchemaModule.MutableSelectionSet {
      public var __data: DataDict
      public init(_data: DataDict) { __data = _data }

      public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("species", String.self),
        .field("skinCovering", GraphQLEnum<MySchemaModule.SkinCovering>?.self),
        .inlineFragment(AsBird.self),
      ] }

      public var species: String {
        get { __data["species"] }
        set { __data["species"] = newValue }
      }
      public var skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? {
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
        skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? = nil
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            MySchemaModule.Interfaces.Animal
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "species": species,
            "skinCovering": skinCovering
        ]))
      }

      /// AllAnimal.AsBird
      ///
      /// Parent Type: `Bird`
      public struct AsBird: MySchemaModule.MutableInlineFragment {
        public var __data: DataDict
        public init(_data: DataDict) { __data = _data }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Bird }
        public static var __selections: [ApolloAPI.Selection] { [
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
        public var skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? {
          get { __data["skinCovering"] }
          set { __data["skinCovering"] = newValue }
        }

        public init(
          wingspan: Double,
          species: String,
          skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? = nil
        ) {
          let objectType = MySchemaModule.Objects.Bird
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "wingspan": wingspan,
              "species": species,
              "skinCovering": skinCovering
          ]))
        }
      }
    }
  }
}
