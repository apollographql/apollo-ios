import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public protocol TypeCase: ApolloAPI.SelectionSet & TypeCase
where Schema == AnimalKingdomAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Crocodile": return AnimalKingdomAPI.Crocodile.self
    case "Dog": return AnimalKingdomAPI.Dog.self
    case "Fish": return AnimalKingdomAPI.Fish.self
    case "Height": return AnimalKingdomAPI.Height.self
    case "Human": return AnimalKingdomAPI.Human.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
    case "Query": return AnimalKingdomAPI.Query.self
    case "Rat": return AnimalKingdomAPI.Rat.self
    default: return nil
    }
  }
}
