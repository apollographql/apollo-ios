// @generated
// This file was automatically generated and should not be edited.

import Apollo

public typealias ID = String

public protocol SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
where Schema == MyCustomProject.Schema {}

public protocol InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
where Schema == MyCustomProject.Schema {}

public protocol MutableSelectionSet: Apollo.MutableRootSelectionSet
where Schema == MyCustomProject.Schema {}

public protocol MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
where Schema == MyCustomProject.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return MyCustomProject.Objects.Query
    case "Human": return MyCustomProject.Objects.Human
    case "Cat": return MyCustomProject.Objects.Cat
    case "Dog": return MyCustomProject.Objects.Dog
    case "Bird": return MyCustomProject.Objects.Bird
    case "Fish": return MyCustomProject.Objects.Fish
    case "Rat": return MyCustomProject.Objects.Rat
    case "PetRock": return MyCustomProject.Objects.PetRock
    case "Crocodile": return MyCustomProject.Objects.Crocodile
    case "Height": return MyCustomProject.Objects.Height
    case "Mutation": return MyCustomProject.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
