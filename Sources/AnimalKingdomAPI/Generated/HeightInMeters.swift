import ApolloAPI

public struct HeightInMeters: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
  public static var selections: [Selection] { [
    .field("height", Height.self),
  ] }

  public var height: Height { data["height"] }

  public struct Height: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
    public static var selections: [Selection] { [
      .field("meters", Int.self),
    ] }

    public var meters: Int { data["meters"] }

  }
}