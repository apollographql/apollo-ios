// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol MySchemaModule_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == MySchemaModule.Schema {}

public protocol MySchemaModule_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == MySchemaModule.Schema {}

public protocol MySchemaModule_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == MySchemaModule.Schema {}

public protocol MySchemaModule_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == MySchemaModule.Schema {}

public extension MySchemaModule {
  typealias ID = String

  typealias SelectionSet = MySchemaModule_SelectionSet

  typealias InlineFragment = MySchemaModule_InlineFragment

  typealias MutableSelectionSet = MySchemaModule_MutableSelectionSet

  typealias MutableInlineFragment = MySchemaModule_MutableInlineFragment

  enum Schema: SchemaConfiguration {
    public static func objectType(forTypename __typename: String) -> Object.Type? {
      switch __typename {
      case "Query": return MySchemaModule.Query.self
      case "Human": return MySchemaModule.Human.self
      case "Cat": return MySchemaModule.Cat.self
      case "Dog": return MySchemaModule.Dog.self
      case "Bird": return MySchemaModule.Bird.self
      case "Fish": return MySchemaModule.Fish.self
      case "Rat": return MySchemaModule.Rat.self
      case "PetRock": return MySchemaModule.PetRock.self
      case "Crocodile": return MySchemaModule.Crocodile.self
      case "Height": return MySchemaModule.Height.self
      case "Mutation": return MySchemaModule.Mutation.self
      default: return nil
      }
    }
  }

}