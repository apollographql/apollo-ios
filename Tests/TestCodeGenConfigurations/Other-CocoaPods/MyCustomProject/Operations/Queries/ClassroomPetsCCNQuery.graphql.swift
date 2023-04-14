// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public class ClassroomPetsCCNQuery: GraphQLQuery {
  public static let operationName: String = "ClassroomPetsCCN"
  public static let document: Apollo.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query ClassroomPetsCCN {
        classroomPets[!]? {
          __typename
          ...ClassroomPetDetailsCCN
        }
      }
      """#,
      fragments: [ClassroomPetDetailsCCN.self]
    ))

  public init() {}

  public struct Data: MyCustomProject.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Apollo.Selection] { [
      .field("classroomPets", [ClassroomPet]?.self),
    ] }

    public var classroomPets: [ClassroomPet]? { __data["classroomPets"] }

    /// ClassroomPet
    ///
    /// Parent Type: `ClassroomPet`
    public struct ClassroomPet: MyCustomProject.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { MyCustomProject.Unions.ClassroomPet }
      public static var __selections: [Apollo.Selection] { [
        .field("__typename", String.self),
        .fragment(ClassroomPetDetailsCCN.self),
      ] }

      public var asAnimal: AsAnimal? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
      }

      /// ClassroomPet.AsAnimal
      ///
      /// Parent Type: `Animal`
      public struct AsAnimal: MyCustomProject.InlineFragment, Apollo.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPetsCCNQuery.Data.ClassroomPet
        public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Animal }
        public static var __mergedSources: [any Apollo.SelectionSet.Type] { [
          ClassroomPetsCCNQuery.Data.ClassroomPet.self,
          ClassroomPetDetailsCCN.AsAnimal.self
        ] }

        public var height: ClassroomPetDetailsCCN.AsAnimal.Height { __data["height"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
        }
      }
    }
  }
}
