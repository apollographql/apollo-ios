// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetails on ClassroomPet {
      __typename
      ... on Animal {
        species
      }
      ... on Pet {
        humanName
      }
      ... on WarmBlooded {
        laysEggs
      }
      ... on Cat {
        bodyTemperature
        isJellicle
      }
      ... on Bird {
        wingspan
      }
      ... on PetRock {
        favoriteToy
      }
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
  public static var __selections: [ApolloAPI.Selection] { [
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
    public init(_data: DataDict) { __data = data }

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
      let objectType = ApolloAPI.Object(
        typename: __typename,
        implementedInterfaces: [
          AnimalKingdomAPI.Interfaces.Animal
      ])
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "species": species
      ]))
    }
  }

  /// AsPet
  ///
  /// Parent Type: `Pet`
  public struct AsPet: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

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
      let objectType = ApolloAPI.Object(
        typename: __typename,
        implementedInterfaces: [
          AnimalKingdomAPI.Interfaces.Pet
      ])
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "humanName": humanName
      ]))
    }
  }

  /// AsWarmBlooded
  ///
  /// Parent Type: `WarmBlooded`
  public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

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
      let objectType = ApolloAPI.Object(
        typename: __typename,
        implementedInterfaces: [
          AnimalKingdomAPI.Interfaces.WarmBlooded,
          AnimalKingdomAPI.Interfaces.Animal
      ])
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "laysEggs": laysEggs,
          "species": species
      ]))
    }
  }

  /// AsCat
  ///
  /// Parent Type: `Cat`
  public struct AsCat: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

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
      let objectType = AnimalKingdomAPI.Objects.Cat
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "bodyTemperature": bodyTemperature,
          "isJellicle": isJellicle,
          "species": species,
          "humanName": humanName,
          "laysEggs": laysEggs
      ]))
    }
  }

  /// AsBird
  ///
  /// Parent Type: `Bird`
  public struct AsBird: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

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
      let objectType = AnimalKingdomAPI.Objects.Bird
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "wingspan": wingspan,
          "species": species,
          "humanName": humanName,
          "laysEggs": laysEggs
      ]))
    }
  }

  /// AsPetRock
  ///
  /// Parent Type: `PetRock`
  public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

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
      let objectType = AnimalKingdomAPI.Objects.PetRock
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "favoriteToy": favoriteToy,
          "humanName": humanName
      ]))
    }
  }
}
