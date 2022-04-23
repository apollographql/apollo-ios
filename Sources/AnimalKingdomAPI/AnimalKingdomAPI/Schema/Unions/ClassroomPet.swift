// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum ClassroomPet: Union, Equatable {
  case Cat(Cat)
  case Bird(Bird)
  case Rat(Rat)
  case PetRock(PetRock)
  case __unknown(Object)

  public init(_ object: Object) {
    switch object {
    case let entity as Cat: self = .Cat(entity)
    case let entity as Bird: self = .Bird(entity)
    case let entity as Rat: self = .Rat(entity)
    case let entity as PetRock: self = .PetRock(entity)
    default: self = .__unknown(object)
    }
  }

  public var object: Object {
    switch self {
    case let .Cat(object as Object),
      let .Bird(object as Object),
      let .Rat(object as Object),
      let .PetRock(object as Object),
      let .__unknown(object):
        return object
    }
  }

  public static let possibleTypes: [Object.Type] = [
    AnimalKingdomAPI.Cat.self,
    AnimalKingdomAPI.Bird.self,
    AnimalKingdomAPI.Rat.self,
    AnimalKingdomAPI.PetRock.self
  ]
}