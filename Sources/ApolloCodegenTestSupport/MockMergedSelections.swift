import Foundation
@testable import ApolloCodegenLib
import XCTest

extension IR.MergedSelections.MergedSource {

  public static func mock(_ field: IR.Field?) throws -> Self {
    self.init(typeInfo: try XCTUnwrap(field?.selectionSet?.typeInfo), fragment: nil)
  }

  public static func mock(_ typeCase: IR.SelectionSet?) throws -> Self {
    self.init(typeInfo: try XCTUnwrap(typeCase?.typeInfo), fragment: nil)
  }

  public static func mock(_ fragment: IR.FragmentSpread?) throws -> Self {
    let fragment = try XCTUnwrap(fragment)
    return self.init(
      typeInfo: fragment.selectionSet.typeInfo,
      fragment: fragment
    )
  }

  public static func mock(for field: IR.Field?, from fragment: IR.FragmentSpread?) throws -> Self {
    self.init(
      typeInfo: try XCTUnwrap(field?.selectionSet?.typeInfo),
      fragment: try XCTUnwrap(fragment)
    )
  }
}
