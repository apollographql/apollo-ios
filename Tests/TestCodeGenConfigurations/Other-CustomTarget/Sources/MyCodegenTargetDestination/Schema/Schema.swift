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
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return MyCodegenTargetDestination.Query.self
    case "Human": return MyCodegenTargetDestination.Human.self
    case "Cat": return MyCodegenTargetDestination.Cat.self
    case "Dog": return MyCodegenTargetDestination.Dog.self
    case "Bird": return MyCodegenTargetDestination.Bird.self
    case "Fish": return MyCodegenTargetDestination.Fish.self
    case "Rat": return MyCodegenTargetDestination.Rat.self
    case "PetRock": return MyCodegenTargetDestination.PetRock.self
    case "Crocodile": return MyCodegenTargetDestination.Crocodile.self
    case "Height": return MyCodegenTargetDestination.Height.self
    case "Mutation": return MyCodegenTargetDestination.Mutation.self
    default: return nil
    }
  }
}
