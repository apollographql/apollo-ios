import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimalKingdomAPI.Schema {}

public protocol TypeCase: ApolloAPI.SelectionSet & ApolloAPI.TypeCase
where Schema == AnimalKingdomAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD:Sources/AnimalKingdomAPI/Generated/AnimalSchema.swift
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
    case "Height": return AnimalKingdomAPI.Height.self
    case "Human": return AnimalKingdomAPI.Human.self
<<<<<<< HEAD
=======
=======
    case "Height": return AnimalKingdomAPI.Height.self
    case "Human": return AnimalKingdomAPI.Human.self
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts):Sources/AnimalKingdomAPI/Generated/Schema.swift
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
=======
    case "Cat": return AnimalKingdomAPI.Cat.self
    case "Bird": return AnimalKingdomAPI.Bird.self
    case "PetRock": return AnimalKingdomAPI.PetRock.self
    case "Height": return AnimalKingdomAPI.Height.self
    case "Human": return AnimalKingdomAPI.Human.self
>>>>>>> e84b84b7 (Added import ApolloAPI to templates)
    default: return nil
    }
  }
}