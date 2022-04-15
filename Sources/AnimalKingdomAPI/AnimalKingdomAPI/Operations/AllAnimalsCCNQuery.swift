// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class AllAnimalsCCNQuery: GraphQLQuery {
  public let operationName: String = "AllAnimalsCCN"
  public let document: DocumentType = .notPersisted(
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
        .field("height", Height?.self),
      ] }

      public var height: Height? { data["height"] }

      /// AllAnimal.Height
      public struct Height: AnimalKingdomAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
        public static var selections: [Selection] { [
          .field("feet", Int?.self),
          .field("inches", Int.self),
        ] }

        public var feet: Int? { data["feet"] }
        public var inches: Int { data["inches"] }
      }
    }
  }
}