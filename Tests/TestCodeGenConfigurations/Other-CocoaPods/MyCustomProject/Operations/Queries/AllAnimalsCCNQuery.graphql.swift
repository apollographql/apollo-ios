// @generated
// This file was automatically generated and should not be edited.

import Apollo
@_exported import enum Apollo.GraphQLEnum
@_exported import enum Apollo.GraphQLNullable

public class AllAnimalsCCNQuery: GraphQLQuery {
  public static let operationName: String = "AllAnimalsCCN"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
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
      """
    ))

  public init() {}

  public struct Data: MyCustomProject.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MyCustomProject.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyCustomProject.Interfaces.Animal }
      public static var __selections: [Selection] { [
        .field("height", Height?.self),
      ] }

      public var height: Height? { __data["height"] }

      /// AllAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: MyCustomProject.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyCustomProject.Objects.Height }
        public static var __selections: [Selection] { [
          .field("feet", Int?.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int? { __data["feet"] }
        public var inches: Int { __data["inches"] }
      }
    }
  }
}
