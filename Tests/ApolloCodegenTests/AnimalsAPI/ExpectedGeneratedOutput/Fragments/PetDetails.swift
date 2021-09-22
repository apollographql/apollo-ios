@testable import CodegenProposalFramework
import AnimalSchema

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
struct PetDetails: AnimalSchema.SelectionSet, Fragment {
  static var __parentType: ParentType { .Interface(AnimalSchema.Pet.self) }
  let data: ResponseDict

  var humanName: String? { data["humanName"] }
  var favoriteToy: String { data["favoriteToy"] }
  var owner: Human? { data["owner"] }

  struct Human: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Human.self) }
    let data: ResponseDict

    var firstName: String { data["firstName"] }
  }
}
