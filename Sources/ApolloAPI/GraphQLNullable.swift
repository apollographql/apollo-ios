import Foundation

/// Indicates the presence of a value, supporting both `nil` and `null` values.
///
/// ``GraphQLNullable`` is generally only used for setting input values on generated ``GraphQLOperation`` objects.
///
/// In GraphQL, explicitly providing a `null` value for an input value to a field argument is
/// semantically different from not providing a value at all (`nil`). This enum allows you to
/// distinguish your input values between `null` and `nil`.
///
/// # Usage
///
/// ### Literals, Enums, and InputObjects
/// A ``GraphQLNullable`` can be converted from most scalar literals, ``GraphQLEnum``, and any
/// generated ``InputObject`` automatically.
///
/// ```swift
/// public init(inputValue: GraphQLNullable<String>)
/// .init(inputValue: "InputValueString")
///
/// public init(episode: GraphQLNullable<GraphQLEnum<StarWarsAPI.Episode>>)
/// .init(episode: .NEWHOPE)
///
/// public init(inputValue: GraphQLNullable<CustomInputObject>)
/// .init(inputValue: CustomInputObject())
/// ```
/// ### Optional Values with the Nil Coalescing Operator
///
/// You can initialize a ``GraphQLNullable`` with an optional value, but you'll need to indicate
/// the default value to use if the optional is `nil`. Usually this value is either
/// ``none`` or ``null``.
/// ```swift
/// .init(inputValue: optionalValue ?? .none)
/// ```
/// or
/// ```swift
/// .init(inputValue: optionalValue ?? .null)
/// ```
///
/// ### Accessing Properties on Wrapped Objects
///
/// ``GraphQLNullable`` uses `@dynamicMemberLookup` to provide access to properties on the wrapped
///  object without unwrapping.
///
///  ```swift
///  let nullableString: GraphQLNullable<String> = "MyString"
///  print(nullableString.count) // 8
///  ```
///  You can also unwrap the wrapped value to access it directly.
///  ```swift
///  let nullableString: GraphQLNullable<String> = "MyString"
///  if let string = nullableString.unwrapped {
///    print(string.count) // 8
///  }
///  ```
/// # See Also
/// [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/October2021/#sec-Null-Value)
@dynamicMemberLookup
public enum GraphQLNullable<Wrapped> {

  /// The absence of a value.
  /// Functionally equivalent to `nil`.
  case none

  /// The presence of an explicity null value.
  /// Functionally equivalent to `NSNull`
  case null

  /// The presence of a value, stored as `Wrapped`
  case some(Wrapped)

  /// The wrapped value if one exists, `nil` if the receiver is ``none`` or ``null``.
  ///
  /// This property can be used to use a `GraphQLNullable` as you would an `Optional`.
  /// ```swift
  /// let childProperty: String? = nullableInputObject.unwrapped?.childProperty
  /// ```
  @inlinable public var unwrapped: Wrapped? {
    guard case let .some(wrapped) = self else { return nil }
    return wrapped
  }

  /// Subscript for `@dynamicMemberLookup`. Accesses values on the wrapped type.
  /// Will return `nil` if the receiver is ``none`` or ``null``.
  ///
  /// This dynamic member subscript allows you to optionally access properties of the wrapped value.
  /// ```swift
  /// let childProperty: String? = nullableInputObject.childProperty
  /// ```
  @inlinable public subscript<T>(dynamicMember path: KeyPath<Wrapped, T>) -> T? {
    unwrapped?[keyPath: path]
  }

}

// MARK: - ExpressibleBy Literal Extensions

extension GraphQLNullable: ExpressibleByNilLiteral {
  /// The `ExpressibleByNilLiteral` Initializer. Initializes as ``none``.
  ///
  /// This initializer allows you to initialize a ``GraphQLNullable`` by assigning `nil`.
  /// ```swift
  /// let GraphQLNullable<String> = nil // .none
  /// ```
  @inlinable public init(nilLiteral: ()) {
    self = .none
  }  
}

extension GraphQLNullable: ExpressibleByUnicodeScalarLiteral
where Wrapped: ExpressibleByUnicodeScalarLiteral {
  @inlinable public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
    self = .some(Wrapped(unicodeScalarLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByExtendedGraphemeClusterLiteral
where Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
  @inlinable public init(extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType) {
    self = .some(Wrapped(extendedGraphemeClusterLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByStringLiteral
where Wrapped: ExpressibleByStringLiteral {
  @inlinable public init(stringLiteral value: Wrapped.StringLiteralType) {
    self = .some(Wrapped(stringLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByIntegerLiteral
where Wrapped: ExpressibleByIntegerLiteral {
  @inlinable public init(integerLiteral value: Wrapped.IntegerLiteralType) {
    self = .some(Wrapped(integerLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByFloatLiteral
where Wrapped: ExpressibleByFloatLiteral {
  @inlinable public init(floatLiteral value: Wrapped.FloatLiteralType) {
    self = .some(Wrapped(floatLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByBooleanLiteral
where Wrapped: ExpressibleByBooleanLiteral {
  @inlinable public init(booleanLiteral value: Wrapped.BooleanLiteralType) {
    self = .some(Wrapped(booleanLiteral: value))
  }
}

extension GraphQLNullable: ExpressibleByArrayLiteral
where Wrapped: _InitializableByArrayLiteralElements {
  @inlinable public init(arrayLiteral elements: Wrapped.ArrayLiteralElement...) {
    self = .some(Wrapped(elements))
  }
}

extension GraphQLNullable: ExpressibleByDictionaryLiteral
where Wrapped: _InitializableByDictionaryLiteralElements {
  @inlinable public init(dictionaryLiteral elements: (Wrapped.Key, Wrapped.Value)...) {
    self = .some(Wrapped(elements))
  }
}

/// A helper protocol used to enable wrapper types to conform to `ExpressibleByArrayLiteral`.
/// Used by ``GraphQLNullable/init(arrayLiteral:)``
public protocol _InitializableByArrayLiteralElements: ExpressibleByArrayLiteral {
  init(_ array: [ArrayLiteralElement])
}
extension Array: _InitializableByArrayLiteralElements {}

/// A helper protocol used to enable wrapper types to conform to `ExpressibleByDictionaryLiteral`.
/// Used by ``GraphQLNullable/init(dictionaryLiteral:)``
public protocol _InitializableByDictionaryLiteralElements: ExpressibleByDictionaryLiteral {
  init(_ elements: [(Key, Value)])
}

extension Dictionary: _InitializableByDictionaryLiteralElements {
  @inlinable public init(_ elements: [(Key, Value)]) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - Custom Type Initialization

public extension GraphQLNullable {
  /// Initializer for use with a ``GraphQLEnum`` value.
  ///
  /// This initializer enables easier creation of the ``GraphQLNullable`` and ``GraphQLEnum``.
  /// ```swift
  /// let value: GraphQLNullable<GraphQLEnum<StarWarsAPI.Episode>>
  ///
  /// value = .init(.NEWHOPE)
  /// // Instead of
  /// value = .init(.case(.NEWHOPE))
  /// ```
  /// - Parameter caseValue: A case of a generated ``EnumType`` to initialize a
  /// `GraphQLNullable<GraphQLEnum<T>` with.
  @inlinable init<T: EnumType>(_ caseValue: T) where Wrapped == GraphQLEnum<T> {
    self = .some(Wrapped(caseValue))
  }

  /// Intializer for use with an ``InputObject`` value.
  /// - Parameter object: The ``InputObject`` to initalize a ``GraphQLNullable`` with.
  @inlinable init(_ object: Wrapped) where Wrapped: InputObject {
    self = .some(object)
  }
}

// MARK: - Nil Coalescing Operator

/// Nil Coalsecing Operator overload for ``GraphQLNullable``
///
/// This operator allows for optional variables to easily be used with ``GraphQLNullable``
/// parameters and a default value.
///
/// ```swift
/// class MyQuery: GraphQLQuery {
///
///   var myVar: GraphQLNullable<String>
///
///   init(myVar: GraphQLNullable<String> { ... }
///  // ...
/// }
///
/// let optionalString: String?
/// let query = MyQuery(myVar: optionalString ?? .none)
/// ```
@inlinable public func ??<T>(lhs: T?, rhs: GraphQLNullable<T>) -> GraphQLNullable<T> {
  if let lhs = lhs {
    return .some(lhs)
  }
  return rhs
}


// MARK: - Hashable/Equatable Conformance

extension GraphQLNullable: Equatable where Wrapped: Equatable {}
extension GraphQLNullable: Hashable where Wrapped: Hashable {}
