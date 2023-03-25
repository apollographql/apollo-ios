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
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  public init(
    __typename: String
  ) {
    self.init(_dataDict: DataDict(data: [
      "__typename": __typename,
      "__fulfilled": Set([
        ObjectIdentifier(Self.self)
      ])
    ]))
  }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetailsCCN
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    public init(
      __typename: String,
      height: Height
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": __typename,
        "height": height._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self),
          ObjectIdentifier(ClassroomPetDetailsCCN.self)
        ])
      ]))
    }

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }

      public init(
        inches: Int
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": AnimalKingdomAPI.Objects.Height.typename,
          "inches": inches,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }
    }
  }
}
