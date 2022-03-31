import Foundation
@testable import ApolloCodegenLib
import XCTest

extension IR.MergedSelections.MergedSource {

  public static func mock(
    _ field: IR.Field?,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> Self {
    self.init(
      typeInfo: try XCTUnwrap(field?.selectionSet?.typeInfo, file: file, line: line),
      fragment: nil
    )
  }

  public static func mock(
    _ typeCase: IR.SelectionSet?,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> Self {
    self.init(
      typeInfo: try XCTUnwrap(typeCase?.typeInfo, file: file, line: line),
      fragment: nil
    )
  }

  public static func mock(
    _ fragment: IR.FragmentSpread?,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> Self {
    let fragment = try XCTUnwrap(fragment, file: file, line: line)
    return self.init(
      typeInfo: fragment.fragment.rootField.selectionSet.typeInfo,
      fragment: fragment.fragment
    )
  }

  public static func mock(
    for field: IR.Field?,
    from fragment: IR.FragmentSpread?,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> Self {
    self.init(
      typeInfo: try XCTUnwrap(field?.selectionSet?.typeInfo, file: file, line: line),
      fragment: try XCTUnwrap(fragment?.fragment, file: file, line: line)
    )
  }
}
