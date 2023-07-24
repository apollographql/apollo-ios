// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ClassroomPetsCCNQuery: GraphQLQuery {
  public static let operationName: String = "ClassroomPetsCCN"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ClassroomPetsCCN { classroomPets[!]? { __typename ...ClassroomPetDetailsCCN } }"#,
      fragments: [ClassroomPetDetailsCCN.self]
    ))

  public init() {}

  public struct Data: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("classroomPets", [ClassroomPet]?.self),
    ] }

    public var classroomPets: [ClassroomPet]? { __data["classroomPets"] }

    public init(
      classroomPets: [ClassroomPet]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Query.typename,
          "classroomPets": classroomPets._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetsCCNQuery.Data.self)
        ]
      ))
    }

    /// ClassroomPet
    ///
    /// Parent Type: `ClassroomPet`
    public struct ClassroomPet: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
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

      public init(
        __typename: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ClassroomPetsCCNQuery.Data.ClassroomPet.self)
          ]
        ))
      }

      /// ClassroomPet.AsAnimal
      ///
      /// Parent Type: `Animal`
      public struct AsAnimal: AnimalKingdomAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClassroomPetsCCNQuery.Data.ClassroomPet
        public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClassroomPetsCCNQuery.Data.ClassroomPet.self,
          ClassroomPetDetailsCCN.AsAnimal.self
        ] }

        public var height: ClassroomPetDetailsCCN.AsAnimal.Height { __data["height"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var classroomPetDetailsCCN: ClassroomPetDetailsCCN { _toFragment() }
        }

        public init(
          __typename: String,
          height: ClassroomPetDetailsCCN.AsAnimal.Height
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
              "height": height._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ClassroomPetsCCNQuery.Data.ClassroomPet.self),
              ObjectIdentifier(ClassroomPetsCCNQuery.Data.ClassroomPet.AsAnimal.self),
              ObjectIdentifier(ClassroomPetDetailsCCN.self),
              ObjectIdentifier(ClassroomPetDetailsCCN.AsAnimal.self)
            ]
          ))
        }
      }
    }
  }
}
