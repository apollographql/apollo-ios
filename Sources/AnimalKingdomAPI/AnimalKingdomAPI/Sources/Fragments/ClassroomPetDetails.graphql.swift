// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ClassroomPetDetails on ClassroomPet { __typename ... on Animal { species } ... on Pet { humanName } ... on WarmBlooded { laysEggs } ... on Cat { bodyTemperature isJellicle } ... on Bird { wingspan } ... on PetRock { favoriteToy } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsAnimal.self),
    .inlineFragment(AsPet.self),
    .inlineFragment(AsWarmBlooded.self),
    .inlineFragment(AsCat.self),
    .inlineFragment(AsBird.self),
    .inlineFragment(AsPetRock.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }
  public var asPet: AsPet? { _asInlineFragment() }
  public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }
  public var asCat: AsCat? { _asInlineFragment() }
  public var asBird: AsBird? { _asInlineFragment() }
  public var asPetRock: AsPetRock? { _asInlineFragment() }

  public init(
    __typename: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ClassroomPetDetails.self)
      ]
    ))
  }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { __data["species"] }

    public init(
      __typename: String,
      species: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
          "species": species,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsAnimal.self)
        ]
      ))
    }
  }

  /// AsPet
  ///
  /// Parent Type: `Pet`
  public struct AsPet: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("humanName", String?.self),
    ] }

    public var humanName: String? { __data["humanName"] }

    public init(
      __typename: String,
      humanName: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
          "humanName": humanName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsPet.self)
        ]
      ))
    }
  }

  /// AsWarmBlooded
  ///
  /// Parent Type: `WarmBlooded`
  public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var laysEggs: Bool { __data["laysEggs"] }
    public var species: String { __data["species"] }

    public init(
      __typename: String,
      laysEggs: Bool,
      species: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
          "laysEggs": laysEggs,
          "species": species,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsWarmBlooded.self),
          ObjectIdentifier(ClassroomPetDetails.AsAnimal.self)
        ]
      ))
    }
  }

  /// AsCat
  ///
  /// Parent Type: `Cat`
  public struct AsCat: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Cat }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("bodyTemperature", Int.self),
      .field("isJellicle", Bool.self),
    ] }

    public var bodyTemperature: Int { __data["bodyTemperature"] }
    public var isJellicle: Bool { __data["isJellicle"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }

    public init(
      bodyTemperature: Int,
      isJellicle: Bool,
      species: String,
      humanName: String? = nil,
      laysEggs: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Cat.typename,
          "bodyTemperature": bodyTemperature,
          "isJellicle": isJellicle,
          "species": species,
          "humanName": humanName,
          "laysEggs": laysEggs,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsCat.self),
          ObjectIdentifier(ClassroomPetDetails.AsAnimal.self),
          ObjectIdentifier(ClassroomPetDetails.AsPet.self),
          ObjectIdentifier(ClassroomPetDetails.AsWarmBlooded.self)
        ]
      ))
    }
  }

  /// AsBird
  ///
  /// Parent Type: `Bird`
  public struct AsBird: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Bird }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("wingspan", Double.self),
    ] }

    public var wingspan: Double { __data["wingspan"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }

    public init(
      wingspan: Double,
      species: String,
      humanName: String? = nil,
      laysEggs: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Bird.typename,
          "wingspan": wingspan,
          "species": species,
          "humanName": humanName,
          "laysEggs": laysEggs,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsBird.self),
          ObjectIdentifier(ClassroomPetDetails.AsAnimal.self),
          ObjectIdentifier(ClassroomPetDetails.AsPet.self),
          ObjectIdentifier(ClassroomPetDetails.AsWarmBlooded.self)
        ]
      ))
    }
  }

  /// AsPetRock
  ///
  /// Parent Type: `PetRock`
  public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.PetRock }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var favoriteToy: String { __data["favoriteToy"] }
    public var humanName: String? { __data["humanName"] }

    public init(
      favoriteToy: String,
      humanName: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.PetRock.typename,
          "favoriteToy": favoriteToy,
          "humanName": humanName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClassroomPetDetails.self),
          ObjectIdentifier(ClassroomPetDetails.AsPetRock.self),
          ObjectIdentifier(ClassroomPetDetails.AsPet.self)
        ]
      ))
    }
  }
}
