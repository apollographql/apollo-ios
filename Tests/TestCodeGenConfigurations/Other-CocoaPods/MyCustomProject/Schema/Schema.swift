// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == MyCustomProject.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == MyCustomProject.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == MyCustomProject.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == MyCustomProject.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return MyCustomProject.Query.self
    case "Human": return MyCustomProject.Human.self
    case "Cat": return MyCustomProject.Cat.self
    case "Dog": return MyCustomProject.Dog.self
    case "Bird": return MyCustomProject.Bird.self
    case "Fish": return MyCustomProject.Fish.self
    case "Rat": return MyCustomProject.Rat.self
    case "PetRock": return MyCustomProject.PetRock.self
    case "Crocodile": return MyCustomProject.Crocodile.self
    case "Height": return MyCustomProject.Height.self
    case "Mutation": return MyCustomProject.Mutation.self
    default: return nil
    }
  }
}
