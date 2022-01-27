public struct PetDetails: API.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(API.Pet.self) }
  public static var selections: [Selection] { [
    .field("humanName", String?.self),
    .field("favoriteToy", String.self),
    .field("owner", Human?.self),
  ] }

  public var humanName: String? { data["humanName"] }
  public var favoriteToy: String { data["favoriteToy"] }
  public var owner: Owner? { data["owner"] }

  public struct Owner: API.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(API.Human.self) }
    public static var selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String { data["firstName"] }

  }
}