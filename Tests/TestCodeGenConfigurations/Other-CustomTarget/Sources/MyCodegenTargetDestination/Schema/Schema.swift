// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == MyCodegenTargetDestination.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == MyCodegenTargetDestination.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == MyCodegenTargetDestination.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == MyCodegenTargetDestination.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return MyCodegenTargetDestination.Objects.Query
    case "Human": return MyCodegenTargetDestination.Objects.Human
    case "Cat": return MyCodegenTargetDestination.Objects.Cat
    case "Dog": return MyCodegenTargetDestination.Objects.Dog
    case "Bird": return MyCodegenTargetDestination.Objects.Bird
    case "Fish": return MyCodegenTargetDestination.Objects.Fish
    case "Rat": return MyCodegenTargetDestination.Objects.Rat
    case "PetRock": return MyCodegenTargetDestination.Objects.PetRock
    case "Crocodile": return MyCodegenTargetDestination.Objects.Crocodile
    case "Height": return MyCodegenTargetDestination.Objects.Height
    case "Mutation": return MyCodegenTargetDestination.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
