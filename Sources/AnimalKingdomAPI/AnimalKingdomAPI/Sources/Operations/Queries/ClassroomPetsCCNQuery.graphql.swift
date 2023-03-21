// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ClassroomPetsCCNQuery: GraphQLQuery {
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

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("classroomPets", [ClassroomPet]?.self),
    ] }

    public var classroomPets: [ClassroomPet]? { __data["classroomPets"] }

    public init(
      classroomPets: [ClassroomPet]? = nil
    ) {
      let objectType = AnimalKingdomAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "classroomPets": classroomPets._fieldData
      ]))
    }

    /// ClassroomPet
    ///
    /// Parent Type: `ClassroomPet`
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(ClassroomPetDetailsCCN.self),
      ] }

      public var asAnimal: AsAnimal? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
      }

      public init(
        __typename: String
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
        ]))
      }

      /// ClassroomPet.AsAnimal
      ///
      /// Parent Type: `Animal`
      public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
        public let __data: DataDict
        public init(_data: DataDict) { __data = data }

        public typealias RootEntityType = ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }

        public var height: ClassroomPetDetailsCCN.AsAnimal.Height { __data["height"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_data: DataDict) { __data = data }

          public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
        }

        public init(
          __typename: String,
          height: ClassroomPetDetailsCCN.AsAnimal.Height
        ) {
          let objectType = ApolloAPI.Object(
            typename: __typename,
            implementedInterfaces: [
              AnimalKingdomAPI.Interfaces.Animal
          ])
          self.init(data: DataDict(
            objectType: objectType,
            data: [
              "__typename": objectType.typename,
              "height": height._fieldData
          ]))
        }
      }
    }
  }
}
