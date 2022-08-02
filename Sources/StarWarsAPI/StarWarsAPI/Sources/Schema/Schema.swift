// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == StarWarsAPI.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == StarWarsAPI.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == StarWarsAPI.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == StarWarsAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func graphQLType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return StarWarsAPI.Query
    case "Human": return StarWarsAPI.Human
    case "Droid": return StarWarsAPI.Droid
    case "Starship": return StarWarsAPI.Starship
    case "Subscription": return StarWarsAPI.Subscription
    case "Review": return StarWarsAPI.Review
    case "Mutation": return StarWarsAPI.Mutation
    default: return nil
    }
  }
}
