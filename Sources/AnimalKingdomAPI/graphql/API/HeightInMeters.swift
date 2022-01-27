public struct HeightInMeters: API.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(API.Animal.self) }
  public static var selections: [Selection] { [
    .field("height", Height.self),
  ] }

  public var height: Height { data["height"] }

  public struct Height: API.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(API.Height.self) }
    public static var selections: [Selection] { [
      .field("meters", Int.self),
    ] }

    public var meters: Int { data["meters"] }

  }
}