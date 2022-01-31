<<<<<<< HEAD:Sources/AnimalKingdomAPI/Generated/PetDetails.swift
import ApolloAPI

public struct PetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: DataDict
  public init(data: DataDict) { self.data = data }

=======
public struct PetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts):Sources/AnimalKingdomAPI/graphql/API/PetDetails.swift
  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
  public static var selections: [Selection] { [
    .field("humanName", String?.self),
    .field("favoriteToy", String.self),
    .field("owner", Human?.self),
  ] }

  public var humanName: String? { data["humanName"] }
  public var favoriteToy: String { data["favoriteToy"] }
  public var owner: Owner? { data["owner"] }

  public struct Owner: AnimalKingdomAPI.SelectionSet {
<<<<<<< HEAD:Sources/AnimalKingdomAPI/Generated/PetDetails.swift
    public let data: DataDict
    public init(data: DataDict) { self.data = data }
=======
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts):Sources/AnimalKingdomAPI/graphql/API/PetDetails.swift

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Human.self) }
    public static var selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String { data["firstName"] }

  }
}