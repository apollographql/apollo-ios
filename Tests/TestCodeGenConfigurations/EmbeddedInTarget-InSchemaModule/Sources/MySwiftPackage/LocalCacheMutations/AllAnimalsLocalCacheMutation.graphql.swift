// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension MyGraphQLSchema {
  class AllAnimalsLocalCacheMutation: LocalCacheMutation {
    public static let operationType: GraphQLOperationType = .query

    public init() {}

    public struct Data: MyGraphQLSchema.MutableSelectionSet {
      public var __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Query }
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
        let objectType = MyGraphQLSchema.Objects.Query
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
      public struct AllAnimal: MyGraphQLSchema.MutableSelectionSet {
        public var __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Interfaces.Animal }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("species", String.self),
          .field("skinCovering", GraphQLEnum<MyGraphQLSchema.SkinCovering>?.self),
          .inlineFragment(AsBird.self),
        ] }

        public var species: String {
          get { __data["species"] }
          set { __data["species"] = newValue }
        }
        public var skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? {
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
          skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? = nil
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              MyGraphQLSchema.Interfaces.Animal
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
        public struct AsBird: MyGraphQLSchema.MutableInlineFragment {
          public var __data: DataDict
          public init(data: DataDict) { __data = data }

          public typealias RootEntityType = AllAnimal
          public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Bird }
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
          public var skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? {
            get { __data["skinCovering"] }
            set { __data["skinCovering"] = newValue }
          }

          public init(
            wingspan: Double,
            species: String,
            skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? = nil
          ) {
            let objectType = MyGraphQLSchema.Objects.Bird
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

}