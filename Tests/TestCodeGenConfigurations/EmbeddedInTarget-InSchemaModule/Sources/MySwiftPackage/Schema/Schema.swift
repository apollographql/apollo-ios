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
    public static func objectType(forTypename __typename: String) -> Object.Type? {
      switch __typename {
      case "Query": return MyGraphQLSchema.Query.self
      case "Human": return MyGraphQLSchema.Human.self
      case "Cat": return MyGraphQLSchema.Cat.self
      case "Dog": return MyGraphQLSchema.Dog.self
      case "Bird": return MyGraphQLSchema.Bird.self
      case "Fish": return MyGraphQLSchema.Fish.self
      case "Rat": return MyGraphQLSchema.Rat.self
      case "PetRock": return MyGraphQLSchema.PetRock.self
      case "Crocodile": return MyGraphQLSchema.Crocodile.self
      case "Height": return MyGraphQLSchema.Height.self
      case "Mutation": return MyGraphQLSchema.Mutation.self
      default: return nil
      }
    }
  }

}