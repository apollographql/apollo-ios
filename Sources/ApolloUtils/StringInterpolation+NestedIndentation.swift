import Foundation

public extension DefaultStringInterpolation {

  /// A String interpolation function that respects nested indentation.
  ///
  /// Example:
  /// ```swift
  /// class Root {
  /// let children: [Root] = []
  /// func description: String {
  ///   var desc = "\(type(of: self)) {"
  ///   children.forEach { child in
  ///     desc += "\n  \(indented: child.debugDescription),"
  ///   }
  ///   if !children.isEmpty { desc += "\n" }
  ///   desc += "\(indented: "}")"
  ///   return desc
  /// }
  /// // Given classes A - E as subclasses of Root
  ///
  /// let root = Root(children: [A(children: [B(), C(children: [D()])]), E()])
  /// print(root.description)
  /// ```
  /// This prints:
  /// Root {
  ///   A {
  ///     B {}
  ///     C {
  ///       D {}
  ///     }
  ///   }
  ///   E {}
  /// }
  mutating func appendInterpolation(indented string: String) {
    let indent = String(stringInterpolation: self).reversed().prefix { " \t".contains($0) }
    if indent.isEmpty {
      appendInterpolation(string)
    } else {
      appendLiteral(string.split(separator: "\n", omittingEmptySubsequences: false).joined(separator: "\n" + indent))
    }
  }
}
