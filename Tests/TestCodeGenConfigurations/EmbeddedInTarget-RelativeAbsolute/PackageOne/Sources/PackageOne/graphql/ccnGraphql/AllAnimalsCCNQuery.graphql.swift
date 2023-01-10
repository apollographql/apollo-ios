// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

class AllAnimalsCCNQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsCCN"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query AllAnimalsCCN {
        allAnimals {
          __typename
          height? {
            __typename
            feet?
            inches!
          }
        }
      }
      """#
    ))

  public init() {}

  public struct Data: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MySchemaModule.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("height", Height?.self),
      ] }

      public var height: Height? { __data["height"] }

      /// AllAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: MySchemaModule.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Height }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("feet", Int?.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int? { __data["feet"] }
        public var inches: Int { __data["inches"] }
      }
    }
  }
}
