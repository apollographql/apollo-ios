@testable import CodegenProposalFramework
import AnimalSchema

/// A response data object for a `ClassroomPetDetails` fragment
struct ClassroomPetDetails: AnimalSchema.SelectionSet, Fragment {
  static var __parentType: ParentType { .Union(AnimalSchema.ClassroomPet.self) }
  let data: ResponseDict

  var asAnimal: AsAnimal? { _asType() }
  var asPet: AsPet? { _asType() }
  var asWarmBlooded: AsWarmBlooded? { _asType() }

  var asCat: AsCat? { _asType() }
  var asBird: AsBird? { _asType() }
  var asPetRock: AsPetRock? { _asType() }

  /// `ClassroomPet.AsAnimal`
  struct AsAnimal: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Interface(AnimalSchema.Animal.self) }
    let data: ResponseDict

    var species: String { data["species"] }
  }

  /// `ClassroomPet.AsPet`
  struct AsPet: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Interface(AnimalSchema.Pet.self) }
    let data: ResponseDict

    var species: String { data["species"] }
    var humanName: String? { data["humanName"] }
  }

  /// `ClassroomPet.AsWarmBlooded`
  struct AsWarmBlooded: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Interface(AnimalSchema.Animal.self) }
    let data: ResponseDict

    var species: String { data["species"] }
    var laysEggs: Bool { data["laysEggs"] }
  }

  /// `ClassroomPet.AsCat`
  struct AsCat: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Cat.self) }
    let data: ResponseDict

    var species: String { data["species"] }
    var humanName: String? { data["humanName"] }
    var laysEggs: Bool { data["laysEggs"] }
    var bodyTemperature: Int { data["bodyTemperature"] }
    var isJellicle: Bool { data["isJellicle"] }
  }

  /// `ClassroomPet.AsBird`
  struct AsBird: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Bird.self) }
    let data: ResponseDict

    var species: String { data["species"] }
    var humanName: String? { data["humanName"] }
    var laysEggs: Bool { data["laysEggs"] }
    var wingspan: Int { data["wingspan"] }
  }

  /// `ClassroomPet.AsPetRock`
  struct AsPetRock: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.PetRock.self) }
    let data: ResponseDict

    var humanName: String? { data["humanName"] }
    var favoriteToy: String { data["favoriteToy"] }
  }
}
