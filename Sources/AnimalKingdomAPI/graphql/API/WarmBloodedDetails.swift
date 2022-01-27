public struct WarmBloodedDetails: API.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(API.WarmBlooded.self) }
  public static var selections: [Selection] { [
    .field("bodyTemperature", Int.self),
    .field("height", Height.self),
  ] }

  public var bodyTemperature: Int { data["bodyTemperature"] }
  public var height: Height { data["height"] }

  public struct Height: API.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(API.Height.self) }
    public static var selections: [Selection] { [
      .field("meters", Int.self),
      .field("yards", Int.self),
    ] }

    public var meters: Int { data["meters"] }
    public var yards: Int { data["yards"] }

  }
}