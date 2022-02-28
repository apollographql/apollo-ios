// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimalKingdomAPICCN.Schema {}

public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
where Schema == AnimalKingdomAPICCN.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return AnimalKingdomAPICCN.Query.self
    case "Height": return AnimalKingdomAPICCN.Height.self
    default: return nil
    }
  }
}