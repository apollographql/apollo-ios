import ApolloAPI

public struct PetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: DataDict
  public init(data: DataDict) { self.data = data }

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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Human.self) }
    public static var selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String { data["firstName"] }

  }
}