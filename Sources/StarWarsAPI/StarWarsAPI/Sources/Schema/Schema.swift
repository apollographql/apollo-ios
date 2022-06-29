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
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return StarWarsAPI.Query.self
    case "Human": return StarWarsAPI.Human.self
    case "Droid": return StarWarsAPI.Droid.self
    case "Starship": return StarWarsAPI.Starship.self
    case "Subscription": return StarWarsAPI.Subscription.self
    case "Review": return StarWarsAPI.Review.self
    case "Mutation": return StarWarsAPI.Mutation.self
    default: return nil
    }
  }
}
