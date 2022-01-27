public struct Data: API.SelectionSet {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Object(API.Query.self) }
  public static var selections: [Selection] { [
    .field("allAnimals", [Animal].self),
  ] }

  public var allAnimals: [AllAnimal] { data["allAnimals"] }

  public struct AllAnimal: API.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(API.Animal.self) }
    public static var selections: [Selection] { [
      .field("height", Height.self),
      .field("species", String.self),
      .field("skinCovering", GraphQLEnum<SkinCovering>?.self),
      .field("predators", [Animal].self),
      .typeCase(AsWarmBlooded.self),
      .typeCase(AsPet.self),
      .typeCase(AsCat.self),
      .typeCase(AsClassroomPet.self),
      .fragment(HeightInMeters.self),
    ] }

    public var height: Height { data["height"] }
    public var species: String { data["species"] }
    public var skinCovering: GraphQLEnum<SkinCovering>? { data["skinCovering"] }
    public var predators: [Predator] { data["predators"] }

    public struct Height: API.SelectionSet {
      public let data: ResponseDict
      public init(data: ResponseDict) { self.data = data }

      public static var __parentType: ParentType { .Object(API.Height.self) }
      public static var selections: [Selection] { [
        .field("feet", Int.self),
        .field("inches", Int.self),
      ] }

      public var feet: Int { data["feet"] }
      public var inches: Int { data["inches"] }
      public var meters: Int { data["meters"] }

    }
    public struct Predator: API.SelectionSet {
      public let data: ResponseDict
      public init(data: ResponseDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(API.Animal.self) }
      public static var selections: [Selection] { [
        .field("species", String.self),
        .typeCase(AsWarmBlooded.self),
      ] }

      public var species: String { data["species"] }

    }
  }
}