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
  public static func graphQLType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return AnimalKingdomAPI.Query
    case "Human": return AnimalKingdomAPI.Human
    case "Cat": return AnimalKingdomAPI.Cat
    case "Dog": return AnimalKingdomAPI.Dog
    case "Bird": return AnimalKingdomAPI.Bird
    case "Fish": return AnimalKingdomAPI.Fish
    case "Rat": return AnimalKingdomAPI.Rat
    case "PetRock": return AnimalKingdomAPI.PetRock
    case "Crocodile": return AnimalKingdomAPI.Crocodile
    case "Height": return AnimalKingdomAPI.Height
    case "Mutation": return AnimalKingdomAPI.Mutation
    default: return nil
    }
  }
}
