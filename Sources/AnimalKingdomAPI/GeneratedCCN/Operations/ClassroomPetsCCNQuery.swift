// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class ClassroomPetsCCNQuery: GraphQLQuery {
  public let operationName: String = "ClassroomPetsCCN"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query ClassroomPetsCCN {
        classroomPets[!]? {
          ...ClassroomPetDetailsCCN
        }
      }
      """,
      fragments: [ClassroomPetDetailsCCN.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("classroomPets", [ClassroomPet]?.self),
    ] }

    public var classroomPets: [ClassroomPet]? { data["classroomPets"] }

    /// ClassroomPet
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
      public static var selections: [Selection] { [
        .fragment(ClassroomPetDetailsCCN.self),
      ] }

      public var asAnimal: AsAnimal? { _asType() }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
      }

      /// ClassroomPet.AsAnimal
      public struct AsAnimal: AnimalKingdomAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }

        public var height: ClassroomPetDetailsCCN.Height { data["height"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
        }
      }
    }
  }
}