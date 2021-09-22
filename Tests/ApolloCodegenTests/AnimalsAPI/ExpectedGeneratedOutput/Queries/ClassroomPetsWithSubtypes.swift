@testable import CodegenProposalFramework
import AnimalSchema

struct ClassroomPetsWithSubtypesQuery {
  let data: ResponseData

  struct ResponseData: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Query.self) }
    let data: ResponseDict

    var classroomPets: [ClassroomPet] { data["classroomPets"] }

    struct ClassroomPet: AnimalSchema.SelectionSet {
      static var __parentType: ParentType { .Union(AnimalSchema.ClassroomPet.self) }
      let data: ResponseDict

      var asAnimal: AsAnimal? { _asType() }
      var asPet: AsPet? { _asType() }
      var asWarmBlooded: AsWarmBlooded? { _asType() }

      var asCat: AsCat? { _asType() }
      var asBird: AsBird? { _asType() }
      var asPetRock: AsPetRock? { _asType() }
      var asRat: AsRat? { _asType() }

      enum SubType {
        case bird(AsBird)
        case cat(AsCat)
        case rat(AsRat)
        case petRock(AsPetRock)
        case other(ClassroomPet)
      }

      var subtype: SubType {
        switch __objectType {
        case is Bird.Type: return .bird(AsBird(data: data))
        case is Cat.Type: return .cat(AsCat(data: data))
        case is Rat.Type: return .rat(AsRat(data: data))
        case is PetRock.Type: return .petRock(AsPetRock(data: data))
        default: return .other(self)
        }
      }

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

      /// `ClassroomPet.AsRat`
      struct AsRat: AnimalSchema.SelectionSet {
        static var __parentType: ParentType { .Object(AnimalSchema.Rat.self) }
        let data: ResponseDict

        var species: String { data["species"] }
        var humanName: String? { data["humanName"] }
        var laysEggs: Bool { data["laysEggs"] }
      }

      /// `ClassroomPet.AsPetRock`
      struct AsPetRock: AnimalSchema.SelectionSet {
        static var __parentType: ParentType { .Object(AnimalSchema.PetRock.self) }
        let data: ResponseDict

        var humanName: String? { data["humanName"] }
        var favoriteToy: String { data["favoriteToy"] }
      }
    }
  }
}
