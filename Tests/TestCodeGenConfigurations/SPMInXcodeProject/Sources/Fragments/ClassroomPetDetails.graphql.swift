// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetails on ClassroomPet {
      __typename
      ... on Animal {
        __typename
        species
      }
      ... on Pet {
        __typename
        humanName
      }
      ... on WarmBlooded {
        __typename
        laysEggs
      }
      ... on Cat {
        __typename
        bodyTemperature
        isJellicle
      }
      ... on Bird {
        __typename
        wingspan
      }
      ... on PetRock {
        __typename
        favoriteToy
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { AnimalKingdomAPI.Unions.ClassroomPet }
  public static var __selections: [Selection] { [
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

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Interfaces.Animal }
    public static var __selections: [Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { __data["species"] }
  }

  /// AsPet
  ///
  /// Parent Type: `Pet`
  public struct AsPet: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Interfaces.Pet }
    public static var __selections: [Selection] { [
      .field("humanName", String?.self),
    ] }

    public var humanName: String? { __data["humanName"] }
  }

  /// AsWarmBlooded
  ///
  /// Parent Type: `WarmBlooded`
  public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
    public static var __selections: [Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var laysEggs: Bool { __data["laysEggs"] }
    public var species: String { __data["species"] }
  }

  /// AsCat
  ///
  /// Parent Type: `Cat`
  public struct AsCat: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Objects.Cat }
    public static var __selections: [Selection] { [
      .field("bodyTemperature", Int.self),
      .field("isJellicle", Bool.self),
    ] }

    public var bodyTemperature: Int { __data["bodyTemperature"] }
    public var isJellicle: Bool { __data["isJellicle"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }
  }

  /// AsBird
  ///
  /// Parent Type: `Bird`
  public struct AsBird: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Objects.Bird }
    public static var __selections: [Selection] { [
      .field("wingspan", Double.self),
    ] }

    public var wingspan: Double { __data["wingspan"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }
  }

  /// AsPetRock
  ///
  /// Parent Type: `PetRock`
  public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { AnimalKingdomAPI.Objects.PetRock }
    public static var __selections: [Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var favoriteToy: String { __data["favoriteToy"] }
    public var humanName: String? { __data["humanName"] }
  }
}
