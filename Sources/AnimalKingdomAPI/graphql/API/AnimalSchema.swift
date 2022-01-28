import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == API.Schema {}

public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
where Schema == API.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Height": return API.Height.self
    case "Human": return API.Human.self
    case "Cat": return API.Cat.self
    case "Bird": return API.Bird.self
    case "PetRock": return API.PetRock.self
    default: return nil
    }
  }
}