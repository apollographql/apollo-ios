import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
where Schema == AnimalKingdomAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
    case "Height": return AnimalKingdomAPI.Height.self
    case "Human": return AnimalKingdomAPI.Human.self
    default: return nil
    }
  }
}