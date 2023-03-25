// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension MyGraphQLSchema {
  class ClassroomPetsCCNQuery: GraphQLQuery {
    public static let operationName: String = "ClassroomPetsCCN"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
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

    public struct Data: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("classroomPets", [ClassroomPet]?.self),
      ] }

      public var classroomPets: [ClassroomPet]? { __data["classroomPets"] }

      /// ClassroomPet
      ///
      /// Parent Type: `ClassroomPet`
      public struct ClassroomPet: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Unions.ClassroomPet }
        public static var __selections: [ApolloAPI.Selection] { [
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
        public struct AsAnimal: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClassroomPet
          public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Interfaces.Animal }

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

}