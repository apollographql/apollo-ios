// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GraphQLAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GraphQLAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GraphQLAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return GraphQLAPI.Objects.Query
    case "Human": return GraphQLAPI.Objects.Human
    case "Cat": return GraphQLAPI.Objects.Cat
    case "Dog": return GraphQLAPI.Objects.Dog
    case "Bird": return GraphQLAPI.Objects.Bird
    case "Fish": return GraphQLAPI.Objects.Fish
    case "Rat": return GraphQLAPI.Objects.Rat
    case "PetRock": return GraphQLAPI.Objects.PetRock
    case "Crocodile": return GraphQLAPI.Objects.Crocodile
    case "Height": return GraphQLAPI.Objects.Height
    case "Mutation": return GraphQLAPI.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
