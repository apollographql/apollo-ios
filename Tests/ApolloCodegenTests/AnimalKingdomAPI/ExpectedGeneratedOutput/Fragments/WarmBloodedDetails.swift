import ApolloAPI
import AnimalKingdomAPI

/// A response data object for a `WarmBloodedDetails` fragment
///
/// ```
/// fragment WarmBloodedDetails on WarmBlooded {
///   bodyTemperature
///   height {
///     meters
///     yards
///   }
/// }
/// ```
public struct WarmBloodedDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.WarmBlooded.self) }
  public static var __selections: [Selection] { [
    .field("bodyTemperature", Int.self),
    .field("height", Height.self),
  ] }

  public var bodyTemperature: Int { data["bodyTemperature"] }
  public var height: Height  { data["height"] }

  public struct Height: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
    public static var __selections: [Selection] { [
      .field("meters", Int.self),
      .field("yards", Int.self),
    ] }

    public var meters: Int { data["meters"] }
    public var yards: Int { data["yards"] }
  }  
}
