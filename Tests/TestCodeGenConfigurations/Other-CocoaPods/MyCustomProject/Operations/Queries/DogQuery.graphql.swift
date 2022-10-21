// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query DogQuery {
        allAnimals {
          __typename
          id
          ... on Dog {
            ...DogFragment
          }
        }
      }
      """,
      fragments: [DogFragment.self]
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
        .field("id", ID.self),
        .inlineFragment(AsDog.self),
      ] }

      public var id: ID { __data["id"] }

      public var asDog: AsDog? { _asInlineFragment() }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: MyCustomProject.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyCustomProject.Objects.Dog }
        public static var __selections: [Selection] { [
          .fragment(DogFragment.self),
        ] }

        public var id: ID { __data["id"] }
        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var dogFragment: DogFragment { _toFragment() }
        }
      }
    }
  }
}
