// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

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

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
      public static var selections: [Selection] { [
        .field("height", Height?.self),
      ] }

      public var height: Height? { __data["height"] }

      /// AllAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: AnimalKingdomAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
        public static var selections: [Selection] { [
          .field("feet", Int?.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int? { __data["feet"] }
        public var inches: Int { __data["inches"] }
      }
    }
  }
}
