// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: Apollo.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query DogQuery {
        allAnimals {
          __typename
          id
          skinCovering
          ... on Dog {
            ...DogFragment
          }
        }
      }
      """#,
      fragments: [DogFragment.self]
    ))

  public init() {}

  public struct Data: MyCustomProject.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Apollo.Selection] { [
      .field("allAnimals", [AllAnimal].self),
    ] }

    public var allAnimals: [AllAnimal] { __data["allAnimals"] }

    /// AllAnimal
    ///
    /// Parent Type: `Animal`
    public struct AllAnimal: MyCustomProject.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Animal }
      public static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .field("id", MyCustomProject.ID.self),
        .field("skinCovering", GraphQLEnum<MyCustomProject.SkinCovering>?.self),
        .inlineFragment(AsDog.self),
      ] }

      public var id: MyCustomProject.ID { __data["id"] }
      public var skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? { __data["skinCovering"] }

      public var asDog: AsDog? { _asInlineFragment() }

      /// AllAnimal.AsDog
      ///
      /// Parent Type: `Dog`
      public struct AsDog: MyCustomProject.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = AllAnimal
        public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Dog }
        public static var __selections: [Apollo.Selection] { [
          .fragment(DogFragment.self),
        ] }

        public var id: MyCustomProject.ID { __data["id"] }
        public var skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? { __data["skinCovering"] }
        public var species: String { __data["species"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var dogFragment: DogFragment { _toFragment() }
        }
      }
    }
  }
}
