// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GraphQLSchemaName.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLSchemaName.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GraphQLSchemaName.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLSchemaName.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return GraphQLSchemaName.Objects.Query
    case "Human": return GraphQLSchemaName.Objects.Human
    case "Cat": return GraphQLSchemaName.Objects.Cat
    case "Dog": return GraphQLSchemaName.Objects.Dog
    case "Bird": return GraphQLSchemaName.Objects.Bird
    case "Fish": return GraphQLSchemaName.Objects.Fish
    case "Rat": return GraphQLSchemaName.Objects.Rat
    case "PetRock": return GraphQLSchemaName.Objects.PetRock
    case "Crocodile": return GraphQLSchemaName.Objects.Crocodile
    case "Height": return GraphQLSchemaName.Objects.Height
    case "Mutation": return GraphQLSchemaName.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
