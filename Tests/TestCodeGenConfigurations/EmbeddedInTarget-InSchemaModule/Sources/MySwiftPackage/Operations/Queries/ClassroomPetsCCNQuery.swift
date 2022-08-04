// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public extension MyGraphQLSchema {
  class ClassroomPetsCCNQuery: GraphQLQuery {
    public static let operationName: String = "ClassroomPetsCCN"
    public static let document: DocumentType = .notPersisted(
      definition: .init(
        """
        query ClassroomPetsCCN {
          classroomPets[!]? {
            __typename
            ...ClassroomPetDetailsCCN
          }
        }
        """,
        fragments: [ClassroomPetDetailsCCN.self]
      ))

    public init() {}

    public struct Data: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Object(MyGraphQLSchema.Query.self) }
      public static var selections: [Selection] { [
        .field("classroomPets", [ClassroomPet]?.self),
      ] }

      public var classroomPets: [ClassroomPet]? { __data["classroomPets"] }

      /// ClassroomPet
      ///
      /// Parent Type: `ClassroomPet`
      public struct ClassroomPet: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Union(MyGraphQLSchema.ClassroomPet.self) }
        public static var selections: [Selection] { [
          .fragment(ClassroomPetDetailsCCN.self),
        ] }

        public var asAnimal: AsAnimal? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
        }

        /// ClassroomPet.AsAnimal
        ///
        /// Parent Type: `Animal`
        public struct AsAnimal: MyGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Interface(MyGraphQLSchema.Animal.self) }

          public var height: ClassroomPetDetailsCCN.AsAnimal.Height { __data["height"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
          }
        }
      }
    }
  }

}