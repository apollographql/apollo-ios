import Foundation

public extension Selection {
  /// The conditions representing a group of `@include/@skip` directives.
  ///
  /// The conditions are a two-dimensional array of `Selection.Condition`s.
  /// The outer array represents groups of conditions joined together with a logical "or".
  /// Conditions in the same inner array are joined together with a logical "and".
  struct Conditions: ExpressibleByArrayLiteral, ExpressibleByStringLiteral, Hashable {
    public let value: [[Condition]]

    @inlinable
    public init(_ value: [[Condition]]) {
      self.value = value
    }

    @inlinable
    public init(arrayLiteral elements: [Condition]...) {
      self.value = Array(elements)
    }

    @inlinable
    public init(_ conditions: [Condition]...) {
      self.value = Array(conditions)
    }

    @inlinable
    public init(stringLiteral string: String) {
      self.value = [[.init(stringLiteral: string)]]
    }

    @inlinable
    public init(_ condition: Condition) {
      self.value = [[condition]]
    }

    @inlinable
    public static func ||(_ lhs: Conditions, rhs: [Condition]) -> Conditions {
      var newValue = lhs.value
      newValue.append(rhs)
      return .init(newValue)
    }

    @inlinable
    public static func ||(_ lhs: Conditions, rhs: Condition) -> Conditions {
      lhs || [rhs]
    }
  }

  struct Condition: ExpressibleByStringLiteral, Hashable {
    public let variableName: String
    public let inverted: Bool

    @inlinable
    public init(
      variableName: String,
      inverted: Bool
    ) {
      self.variableName = variableName
      self.inverted = inverted;
    }

    @inlinable
    public init(stringLiteral value: StringLiteralType) {
      self.variableName = value
      self.inverted = false
    }

    @inlinable
    public static prefix func !(value: Condition) -> Condition {
      .init(variableName: value.variableName, inverted: !value.inverted)
    }

    @inlinable
    public static func &&(_ lhs: Condition, rhs: Condition) -> [Condition] {
      [lhs, rhs]
    }

    @inlinable
    public static func &&(_ lhs: [Condition], rhs: Condition) -> [Condition] {
      var newValue = lhs
      newValue.append(rhs)
      return newValue
    }

    @inlinable
    public static func ||(_ lhs: Condition, rhs: Condition) -> Conditions {
      .init([[lhs], [rhs]])
    }

    @inlinable
    public static func ||(_ lhs: [Condition], rhs: Condition) -> Conditions {
      .init([lhs, [rhs]])
    }

  }
}

// MARK: - Evaluation

// MARK: Conditions - Or Group
public extension Selection.Conditions {
  func evaluate(with variables: GraphQLOperation.Variables?) -> Bool {
    for andGroup in value {
      if andGroup.evaluate(with: variables) {
        return true
      }
    }
    return false
  }
}

// MARK: Conditions - And Group
fileprivate extension Array where Element == Selection.Condition {
  func evaluate(with variables: GraphQLOperation.Variables?) -> Bool {
    for condition in self {
      if !condition.evaluate(with: variables) {
        return false
      }
    }
    return true
  }
}

// MARK: Conditions - Individual
fileprivate extension Selection.Condition {
  func evaluate(with variables: GraphQLOperation.Variables?) -> Bool {
    guard let boolValue = variables?[variableName] as? Bool else {
      return false
    }
    return inverted ? !boolValue : boolValue
  }

}
