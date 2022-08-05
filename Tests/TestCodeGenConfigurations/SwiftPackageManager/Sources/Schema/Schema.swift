// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GraphQLSchemaName.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLSchemaName.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GraphQLSchemaName.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLSchemaName.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return GraphQLSchemaName.Query.self
    case "Human": return GraphQLSchemaName.Human.self
    case "Cat": return GraphQLSchemaName.Cat.self
    case "Dog": return GraphQLSchemaName.Dog.self
    case "Bird": return GraphQLSchemaName.Bird.self
    case "Fish": return GraphQLSchemaName.Fish.self
    case "Rat": return GraphQLSchemaName.Rat.self
    case "PetRock": return GraphQLSchemaName.PetRock.self
    case "Crocodile": return GraphQLSchemaName.Crocodile.self
    case "Height": return GraphQLSchemaName.Height.self
    case "Mutation": return GraphQLSchemaName.Mutation.self
    default: return nil
    }
  }
}
