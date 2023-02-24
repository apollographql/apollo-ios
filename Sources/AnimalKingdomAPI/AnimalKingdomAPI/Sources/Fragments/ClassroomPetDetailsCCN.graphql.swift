// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ClassroomPetDetailsCCN: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetailsCCN on ClassroomPet {
      __typename
      ... on Animal {
        height {
          __typename
          inches!
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
  public static var __selections: [ApolloAPI.Selection] { [
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

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

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    public init(
      __typename: String,
      height: Height
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

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }

      public init(
        inches: Int
      ) {
        let objectType = AnimalKingdomAPI.Objects.Height
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "inches": inches
        ]))
      }
    }
  }
}
