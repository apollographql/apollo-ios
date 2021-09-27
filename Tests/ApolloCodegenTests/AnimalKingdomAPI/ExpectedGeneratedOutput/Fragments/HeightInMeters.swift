@testable import CodegenProposalFramework
import AnimalSchema

/// A response data object for a `HeightInMeters` fragment
///
/// ```
/// fragment HeightInMeters on Animal {
///   height {
///     meters
///   }
/// }
/// ```
struct HeightInMeters: AnimalSchema.SelectionSet, Fragment {
  static var __parentType: ParentType { .Interface(AnimalSchema.Animal.self) }
  let data: ResponseDict

  var height: Height  { data["height"] }

  struct Height: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Height.self) }
    let data: ResponseDict

    var meters: Int { data["meters"] }
  }
}
