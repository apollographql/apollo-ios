// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetails on ClassroomPet {
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

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
  public static var selections: [Selection] { [
    .typeCase(AsAnimal.self),
    .typeCase(AsPet.self),
    .typeCase(AsWarmBlooded.self),
    .typeCase(AsCat.self),
    .typeCase(AsBird.self),
    .typeCase(AsPetRock.self),
  ] }

  public var asAnimal: AsAnimal? { _asType() }
  public var asPet: AsPet? { _asType() }
  public var asWarmBlooded: AsWarmBlooded? { _asType() }
  public var asCat: AsCat? { _asType() }
  public var asBird: AsBird? { _asType() }
  public var asPetRock: AsPetRock? { _asType() }

  /// AsAnimal
  public struct AsAnimal: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    public static var selections: [Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { data["species"] }
  }

  /// AsPet
  public struct AsPet: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
    public static var selections: [Selection] { [
      .field("humanName", String?.self),
    ] }

    public var humanName: String? { data["humanName"] }
  }

  /// AsWarmBlooded
  public struct AsWarmBlooded: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
    public static var selections: [Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var laysEggs: Bool { data["laysEggs"] }
    public var species: String { data["species"] }
  }

  /// AsCat
  public struct AsCat: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
    public static var selections: [Selection] { [
      .field("bodyTemperature", Int.self),
      .field("isJellicle", Bool.self),
    ] }

    public var bodyTemperature: Int { data["bodyTemperature"] }
    public var isJellicle: Bool { data["isJellicle"] }
    public var species: String { data["species"] }
    public var humanName: String? { data["humanName"] }
    public var laysEggs: Bool { data["laysEggs"] }
  }

  /// AsBird
  public struct AsBird: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
    public static var selections: [Selection] { [
      .field("wingspan", Float.self),
    ] }

    public var wingspan: Float { data["wingspan"] }
    public var species: String { data["species"] }
    public var humanName: String? { data["humanName"] }
    public var laysEggs: Bool { data["laysEggs"] }
  }

  /// AsPetRock
  public struct AsPetRock: AnimalKingdomAPI.TypeCase {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.PetRock.self) }
    public static var selections: [Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var favoriteToy: String { data["favoriteToy"] }
    public var humanName: String? { data["humanName"] }
  }
}