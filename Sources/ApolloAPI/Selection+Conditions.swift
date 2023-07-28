import Foundation

public extension Selection {
  /// The conditions representing a group of `@include/@skip` directives.
  ///
  /// The conditions are a two-dimensional array of `Selection.Condition`s.
  /// The outer array represents groups of conditions joined together with a logical "or".
  /// Conditions in the same inner array are joined together with a logical "and".
  struct Conditions: Hashable {
    public let value: [[Condition]]

    public init(_ value: [[Condition]]) {
      self.value = value
    }

    public init(_ conditions: [Condition]...) {
      self.value = Array(conditions)
    }

    public init(_ condition: Condition) {
      self.value = [[condition]]
    }

    @inlinable public static func ||(_ lhs: Conditions, rhs: [Condition]) -> Conditions {
      var newValue = lhs.value
      newValue.append(rhs)
      return .init(newValue)
    }

    @inlinable public static func ||(_ lhs: Conditions, rhs: Condition) -> Conditions {
      lhs || [rhs]
    }
  }

  enum Condition: ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, Hashable {
    case value(Bool)
    case variable(name: String, inverted: Bool)

    public init(
      variableName: String,
      inverted: Bool
    ) {
      self = .variable(name: variableName, inverted: inverted)
    }

    public init(stringLiteral value: StringLiteralType) {
      self = .variable(name: value, inverted: false)
    }

    public init(booleanLiteral value: BooleanLiteralType) {
      self = .value(value)
    }

    @inlinable public static func `if`(_ condition: StringLiteralType) -> Condition {
      .variable(name: condition, inverted: false)
    }

    @inlinable public static func `if`(_ condition: Condition) -> Condition {
      condition
    }

    @inlinable public static prefix func !(condition: Condition) -> Condition {
      switch condition {
      case let .value(value):
        return .value(!value)
      case let .variable(name, inverted):
        return .init(variableName: name, inverted: !inverted)
      }
    }

    @inlinable public static func &&(_ lhs: Condition, rhs: Condition) -> [Condition] {
      [lhs, rhs]
    }

    @inlinable public static func &&(_ lhs: [Condition], rhs: Condition) -> [Condition] {
      var newValue = lhs
      newValue.append(rhs)
      return newValue
    }

    @inlinable public static func ||(_ lhs: Condition, rhs: Condition) -> Conditions {
      .init([[lhs], [rhs]])
    }

    @inlinable public static func ||(_ lhs: [Condition], rhs: Condition) -> Conditions {
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
    switch self {
    case let .value(value):
      return value
    case let .variable(variableName, inverted):
      switch variables?[variableName] {
      case let boolValue as Bool:
        return inverted ? !boolValue : boolValue

      case let nullable as GraphQLNullable<Bool>:
        let evaluated = nullable.unwrapped ?? false
        return inverted ? !evaluated : evaluated

      case .none:
        return false

      case let .some(wrapped):
        fatalError("Expected Bool for \(variableName), got \(wrapped)")
      }
    }
  }
}
