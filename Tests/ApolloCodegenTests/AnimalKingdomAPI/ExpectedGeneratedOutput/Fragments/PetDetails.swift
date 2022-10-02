import ApolloAPI
import AnimalKingdomAPI

/// A response data object for a `PetDetails` fragment
///
/// ```
/// fragment PetDetails on Pet {
///  humanName
///  favoriteToy
///  owner {
///    firstName
///  }
/// }
/// ```
public struct PetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
  public static var __selections: [Selection] { [
    .field("humanName", String.self),
    .field("favoriteToy", String.self),
    .field("owner", Owner.self),
  ] }

  public var humanName: String? { data["humanName"] }
  public var favoriteToy: String { data["favoriteToy"] }
  public var owner: Owner? { data["owner"] }

  public struct Owner: AnimalKingdomAPI.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Human.self) }

    public var firstName: String { data["firstName"] }
  }
}
