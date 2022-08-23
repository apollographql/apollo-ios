// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimalKingdomAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == AnimalKingdomAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == AnimalKingdomAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == AnimalKingdomAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  @inlinable public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return AnimalKingdomAPI.Objects.Query
    case "Human": return AnimalKingdomAPI.Objects.Human
    case "Cat": return AnimalKingdomAPI.Objects.Cat
    case "Dog": return AnimalKingdomAPI.Objects.Dog
    case "Bird": return AnimalKingdomAPI.Objects.Bird
    case "Fish": return AnimalKingdomAPI.Objects.Fish
    case "Rat": return AnimalKingdomAPI.Objects.Rat
    case "PetRock": return AnimalKingdomAPI.Objects.PetRock
    case "Crocodile": return AnimalKingdomAPI.Objects.Crocodile
    case "Height": return AnimalKingdomAPI.Objects.Height
    case "Mutation": return AnimalKingdomAPI.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
