// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct HeightInMeters: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeightInMeters on Animal {
      height {
        meters
      }
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
  public static var selections: [Selection] { [
    .field("height", Height.self),
  ] }

  public var height: Height { data["height"] }

  /// Height
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