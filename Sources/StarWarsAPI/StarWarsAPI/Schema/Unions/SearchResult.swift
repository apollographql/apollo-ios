// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum SearchResult: Union, Equatable {
  case Human(Human)
  case Droid(Droid)
  case Starship(Starship)
  case __unknown(Object)

  public init(_ object: Object) {
    switch object {
    case let entity as Human: self = .Human(entity)
    case let entity as Droid: self = .Droid(entity)
    case let entity as Starship: self = .Starship(entity)
    default: self = .__unknown(object)
    }
  }

  public var object: Object {
    switch self {
    case let .Human(object as Object),
      let .Droid(object as Object),
      let .Starship(object as Object),
      let .__unknown(object):
        return object
    }
  }

  public static let possibleTypes: [Object.Type] = [
    StarWarsAPI.Human.self,
    StarWarsAPI.Droid.self,
    StarWarsAPI.Starship.self
  ]
}