// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == AnimalKingdomAPI.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == AnimalKingdomAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return AnimalKingdomAPI.Query.self
    case "Human": return AnimalKingdomAPI.Human.self
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Dog": return AnimalKingdomAPI.Dog.self
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "Fish": return AnimalKingdomAPI.Fish.self
    case "Rat": return AnimalKingdomAPI.Rat.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
    case "Crocodile": return AnimalKingdomAPI.Crocodile.self
    case "Height": return AnimalKingdomAPI.Height.self
    case "Mutation": return AnimalKingdomAPI.Mutation.self
    default: return nil
    }
  }
}