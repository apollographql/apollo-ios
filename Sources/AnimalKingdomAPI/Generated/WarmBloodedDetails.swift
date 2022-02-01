import ApolloAPI

public struct WarmBloodedDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment WarmBloodedDetails on WarmBlooded {
      bodyTemperature
      height {
        meters
        yards
      }
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
  public static var selections: [Selection] { [
    .field("bodyTemperature", Int.self),
    .field("height", Height.self),
  ] }

  public var bodyTemperature: Int { data["bodyTemperature"] }
  public var height: Height { data["height"] }

  public struct Height: AnimalKingdomAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
    public static var selections: [Selection] { [
      .field("meters", Int.self),
      .field("yards", Int.self),
    ] }

    public var meters: Int { data["meters"] }
    public var yards: Int { data["yards"] }
  }
}