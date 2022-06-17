import Foundation

/// Represents an input value to an argument on a `Selection.Field`'s `Arguments`.
///
/// - See: [GraphQLSpec - Input Values](http://spec.graphql.org/June2018/#sec-Input-Values)
public indirect enum InputValue {
  /// A direct input value, valid types are `String`, `Int` `Float` and `Bool`.
  /// For enum input values, the enum cases's `rawValue` as a `String` should be used.
  case scalar(ScalarType)

  /// A variable input value to be evaluated using the operation's `variables` dictionary at runtime.
  ///
  /// `.variable` should only be used as the value for an argument in a `Selection.Field`.
  /// A `.variable` value should not be included in an operation's `variables` dictionary.
  case variable(String)

  /// A GraphQL "List" input value.
  /// - See: [GraphQLSpec - Input Values - List Value](http://spec.graphql.org/June2018/#sec-List-Value)
  case list([InputValue])

  /// A GraphQL "InputObject" input value. Represented as a dictionary of input values.
  /// - See: [GraphQLSpec - Input Values - Input Object Values](http://spec.graphql.org/June2018/#sec-Input-Object-Values)
  case object([String: InputValue])

  /// A null input value.
  ///
  /// A null input value indicates an intentional inclusion of a value for a field argument as null.
  /// - See: [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/June2018/#sec-Null-Value)
  case null
}

// MARK: - ExpressibleBy Literal Extensions

extension InputValue: ExpressibleByStringLiteral {
  @inlinable public init(stringLiteral value: StringLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByIntegerLiteral {
  @inlinable public init(integerLiteral value: IntegerLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByFloatLiteral {
  @inlinable public init(floatLiteral value: FloatLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByBooleanLiteral {
  @inlinable public init(booleanLiteral value: BooleanLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByArrayLiteral {
  @inlinable public init(arrayLiteral elements: InputValue...) {
    self = .list(Array(elements.map { $0 }))
  }
}

extension InputValue: ExpressibleByDictionaryLiteral {
  @inlinable public init(dictionaryLiteral elements: (String, InputValue)...) {
    self = .object(Dictionary(elements.map{ ($0.0, $0.1) },
                              uniquingKeysWith: { (_, last) in last }))
  }
}

// MARK: Hashable Conformance

extension InputValue: Hashable {
  public static func == (lhs: InputValue, rhs: InputValue) -> Bool {
    switch (lhs, rhs) {
    case let (.variable(lhsValue), .variable(rhsValue)),
         let (.scalar(lhsValue as String), .scalar(rhsValue as String)):
      return lhsValue == rhsValue
    case let (.scalar(lhsValue as Bool), .scalar(rhsValue as Bool)):
      return lhsValue == rhsValue
    case let (.scalar(lhsValue as Int), .scalar(rhsValue as Int)):
      return lhsValue == rhsValue
    case let (.scalar(lhsValue as Float), .scalar(rhsValue as Float)):
      return lhsValue == rhsValue
    case let (.scalar(lhsValue as Double), .scalar(rhsValue as Double)):
      return lhsValue == rhsValue
    case let (.list(lhsValue), .list(rhsValue)):
      return lhsValue.elementsEqual(rhsValue)
    case let (.object(lhsValue), .object(rhsValue)):
      return lhsValue.elementsEqual(rhsValue, by: { $0.key == $1.key && $0.value == $1.value })
    case (.null, .null):
      return true
    default: return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
}
