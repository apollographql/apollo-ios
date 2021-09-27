@testable import CodegenProposalFramework
import AnimalSchema

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
struct WarmBloodedDetails: AnimalSchema.SelectionSet, Fragment {
  static var __parentType: ParentType { .Interface(AnimalSchema.WarmBlooded.self) }

  let data: ResponseDict

  var bodyTemperature: Int { data["bodyTemperature"] }
  var height: Height  { data["height"] }

  struct Height: AnimalSchema.SelectionSet {
    static var __parentType: ParentType { .Object(AnimalSchema.Height.self) }
    let data: ResponseDict

    var meters: Int { data["meters"] }
    var yards: Int { data["yards"] }
  }  
}
