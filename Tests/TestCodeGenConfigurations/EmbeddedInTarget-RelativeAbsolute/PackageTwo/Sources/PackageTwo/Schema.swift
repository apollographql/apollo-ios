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
    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return MySchemaModule.Objects.Query
      case "Human": return MySchemaModule.Objects.Human
      case "Cat": return MySchemaModule.Objects.Cat
      case "Dog": return MySchemaModule.Objects.Dog
      case "Bird": return MySchemaModule.Objects.Bird
      case "Fish": return MySchemaModule.Objects.Fish
      case "Rat": return MySchemaModule.Objects.Rat
      case "PetRock": return MySchemaModule.Objects.PetRock
      case "Crocodile": return MySchemaModule.Objects.Crocodile
      case "Height": return MySchemaModule.Objects.Height
      case "Mutation": return MySchemaModule.Objects.Mutation
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}