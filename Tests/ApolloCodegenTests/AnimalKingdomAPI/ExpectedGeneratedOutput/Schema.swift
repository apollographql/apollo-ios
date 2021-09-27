import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}
public protocol TypeCase: ApolloAPI.SelectionSet & RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Bird": return Bird.self
    case "Cat": return Cat.self
    case "Crocodile": return Crocodile.self
    case "Dog": return Dog.self
    case "Fish": return Fish.self
    case "Height": return Height.self
    case "Human": return Human.self
    case "PetRock": return PetRock.self
    case "Query": return Query.self
    case "Rat": return Rat.self
    default: return nil
    }
  }
}
