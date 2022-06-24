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
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
  public static var selections: [Selection] { [
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
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    public static var selections: [Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { __data["species"] }
  }

  /// AsPet
  public struct AsPet: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
    public static var selections: [Selection] { [
      .field("humanName", String?.self),
    ] }

    public var humanName: String? { __data["humanName"] }
  }

  /// AsWarmBlooded
  public struct AsWarmBlooded: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
    public static var selections: [Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var laysEggs: Bool { __data["laysEggs"] }
    public var species: String { __data["species"] }
  }

  /// AsCat
  public struct AsCat: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
    public static var selections: [Selection] { [
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
  public struct AsBird: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
    public static var selections: [Selection] { [
      .field("wingspan", Double.self),
    ] }

    public var wingspan: Double { __data["wingspan"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }
  }

  /// AsPetRock
  public struct AsPetRock: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.PetRock.self) }
    public static var selections: [Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var favoriteToy: String { __data["favoriteToy"] }
    public var humanName: String? { __data["humanName"] }
  }
}