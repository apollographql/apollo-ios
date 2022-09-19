import ApolloAPI
import AnimalKingdomAPI

/// A response data object for a `ClassroomPetDetails` fragment
///
/// ```
/// fragment ClassroomPetDetails on ClassroomPet {
///   ... on Animal {
///    species
///   }
///   ... on Pet {
///     humanName
///   }
///   ... on WarmBlooded {
///     laysEggs
///   }
///   ... on Cat {
///     bodyTemperature
///     isJellicle
///   }
///   ... on Bird {
///     wingspan
///   }
///   ... on PetRock {
///     favoriteToy
///   }
/// }
/// ```
public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }

  public var asAnimal: AsAnimal? { _asType() }
  public var asPet: AsPet? { _asType() }
  public var asWarmBlooded: AsWarmBlooded? { _asType() }

  public var asCat: AsCat? { _asType() }
  public var asBird: AsBird? { _asType() }
  public var asPetRock: AsPetRock? { _asType() }

  /// `ClassroomPet.AsAnimal`
  public struct AsAnimal: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    public static var __selections: [Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { data["species"] }
  }

  /// `ClassroomPet.AsPet`
  public struct AsPet: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
    public static var __selections: [Selection] { [
      .field("humanName", String.self),
    ] }

    public var species: String { data["species"] }
    public var humanName: String? { data["humanName"] }
  }

  /// `ClassroomPet.AsWarmBlooded`
  public struct AsWarmBlooded: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    public static var __selections: [Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var species: String { data["species"] }
    public var laysEggs: Bool { data["laysEggs"] }
  }

  /// `ClassroomPet.AsCat`
  public struct AsCat: AnimalSchema.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
    public static var __selections: [Selection] { [
      .field("bodyTemperature", Int.self),
      .field("isJellicle", Bool.self),
    ] }

    public var species: String { data["species"] }
    public var humanName: String? { data["humanName"] }
    public var laysEggs: Bool { data["laysEggs"] }
    public var bodyTemperature: Int { data["bodyTemperature"] }
    public var isJellicle: Bool { data["isJellicle"] }
  }

  /// `ClassroomPet.AsBird`
  public struct AsBird: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }
    public static var __selections: [Selection] { [
      .field("wingspan", Int.self),
    ] }

    public var species: String { data["species"] }
    public var humanName: String? { data["humanName"] }
    public var laysEggs: Bool { data["laysEggs"] }
    public var wingspan: Int { data["wingspan"] }
  }

  /// `ClassroomPet.AsPetRock`
  public struct AsPetRock: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.PetRock.self) }
    public static var __selections: [Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var humanName: String? { data["humanName"] }
    public var favoriteToy: String { data["favoriteToy"] }
  }
}
