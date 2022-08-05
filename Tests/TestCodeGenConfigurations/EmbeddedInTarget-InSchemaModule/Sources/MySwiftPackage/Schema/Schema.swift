// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol MyGraphQLSchema_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == MyGraphQLSchema.Schema {}

public protocol MyGraphQLSchema_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == MyGraphQLSchema.Schema {}

public protocol MyGraphQLSchema_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == MyGraphQLSchema.Schema {}

public protocol MyGraphQLSchema_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == MyGraphQLSchema.Schema {}

public extension MyGraphQLSchema {
  typealias ID = String

  typealias SelectionSet = MyGraphQLSchema_SelectionSet

  typealias InlineFragment = MyGraphQLSchema_InlineFragment

  typealias MutableSelectionSet = MyGraphQLSchema_MutableSelectionSet

  typealias MutableInlineFragment = MyGraphQLSchema_MutableInlineFragment

  enum Schema: SchemaConfiguration {
    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return MyGraphQLSchema.Objects.Query
      case "Human": return MyGraphQLSchema.Objects.Human
      case "Cat": return MyGraphQLSchema.Objects.Cat
      case "Dog": return MyGraphQLSchema.Objects.Dog
      case "Bird": return MyGraphQLSchema.Objects.Bird
      case "Fish": return MyGraphQLSchema.Objects.Fish
      case "Rat": return MyGraphQLSchema.Objects.Rat
      case "PetRock": return MyGraphQLSchema.Objects.PetRock
      case "Crocodile": return MyGraphQLSchema.Objects.Crocodile
      case "Height": return MyGraphQLSchema.Objects.Height
      case "Mutation": return MyGraphQLSchema.Objects.Mutation
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}