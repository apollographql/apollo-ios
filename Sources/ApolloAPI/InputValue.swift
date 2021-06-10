import Foundation

/// Represents an input value to an argument on a `GraphQLField`'s `FieldArguments`.
///
/// - See: [GraphQLSpec - Input Values](http://spec.graphql.org/June2018/#sec-Input-Values)
public indirect enum InputValue {
  /// A direct input value, valid types are `String`, `Int` `Float` and `Bool`.
  /// For enum input values, the enum cases's `rawValue` as a `String` should be used.
  case scalar(ScalarType)

  /// A variable input value to be evaluated using the operation's `variables` dictionary at runtime.
  case variable(String)

  /// A GraphQL "List" input value.
  /// - See: [GraphQLSpec - Input Values - List Value](http://spec.graphql.org/June2018/#sec-List-Value)
  case list([InputValue])

  /// A GraphQL "InputObject" input value. Represented as a dictionary of input values.
  /// - See: [GraphQLSpec - Input Values - Input Object Values](http://spec.graphql.org/June2018/#sec-Input-Object-Values)
  case object([String: InputValue])

  /// A null input value.
  /// - See: [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/June2018/#sec-Null-Value)
  case none
}

extension InputValue: ExpressibleByNilLiteral {
  @inlinable public init(nilLiteral: ()) {
    self = .none
  }
}

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
    self = .list(Array(elements))
  }
}

extension InputValue: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, InputValue)...) {
    self = .object(Dictionary(elements, uniquingKeysWith: { (_, last) in last }))
  }
}
