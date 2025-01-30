/// A generic enum type that wraps an ``EnumType`` from a generated GraphQL schema.
///
/// ``GraphQLEnum`` provides an ``unknown(_:)`` case that is used when the response returns a value
/// that is not recognized as a valid enum case. This is usually caused by future cases added to
/// the enum on the schema after code generation.
public enum GraphQLEnum<T: EnumType>: CaseIterable, Sendable, Hashable, RawRepresentable {
  public typealias RawValue = String

  /// A recognized case of the wrapped enum.
  case `case`(T)

  /// An unrecognized value for the enum.
  /// The associated value exposes the raw `String` name of the unknown enum case.
  case unknown(String)

  /// Initializer for use with a value of the wrapped ``EnumType``
  ///
  /// - Parameter caseValue: A value of the wrapped ``EnumType``
  @inlinable public init(_ caseValue: T) {
    self = .case(caseValue)
  }

  /// Initializer for use with a raw value `String`. This initializer is used for initializing an
  /// enum from a GraphQL response value.
  ///
  /// The `rawValue` should represent a raw value for a case of the wrapped ``EnumType``, or an
  /// ``unknown(_:)`` case with the `rawValue` will be returned.
  ///
  /// - Parameter rawValue: The `String` value representing the enum value in a GraphQL response
  @inlinable public init(rawValue: String) {
    guard let caseValue = T(rawValue: rawValue) else {
      self = .unknown(rawValue)
      return
    }
    self = .case(caseValue)
  }

  /// Convenience initializer for use with a raw value `String`. This initializer is used for
  /// initializing an enum from a GraphQL response value.
  ///
  /// The `rawValue` should represent a raw value for a case of the wrapped ``EnumType``, or an
  /// `unknown` case with the `rawValue` will be returned.
  ///
  /// - Parameter rawValue: The `String` value representing the enum value in a GraphQL response
  @inlinable public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }

  /// The underlying enum case. If the value is ``unknown(_:)``, this will be `nil`.
  @inlinable public var value: T? {
    switch self {
    case let .case(value): return value
    default: return nil
    }
  }

  /// The `String` value representing the enum value in a GraphQL response.
  @inlinable public var rawValue: String {
    switch self {
    case let .case(value): return value.rawValue
    case let .unknown(value): return value
    }
  }

  /// A collection of all known values of the wrapped enum.
  /// This collection does not include the `unknown` case.
  @inlinable public static var allCases: [GraphQLEnum<T>] {
    return T.allCases.map { .case($0) }
  }

}

// MARK: CustomScalarType
extension GraphQLEnum: CustomScalarType {
  @inlinable public init(_jsonValue: JSONValue) throws {
    guard let stringData = _jsonValue as? String else {
      throw JSONDecodingError.couldNotConvert(value: _jsonValue, to: String.self)      
    }
    self.init(rawValue: stringData)
  }  
}

// MARK: Equatable
extension GraphQLEnum {
  @inlinable public static func ==(lhs: GraphQLEnum<T>, rhs: GraphQLEnum<T>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  @inlinable public static func ==(lhs: GraphQLEnum<T>, rhs: T) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  @inlinable public static func !=(lhs: GraphQLEnum<T>, rhs: T) -> Bool {
    return lhs.rawValue != rhs.rawValue
  }
}

// MARK: Optional<GraphQLEnum<T>> Equatable

@inlinable public func ==<T: RawRepresentable & CaseIterable>(lhs: GraphQLEnum<T>?, rhs: T) -> Bool
where T.RawValue == String {
  return lhs?.rawValue == rhs.rawValue
}

@inlinable public func !=<T: RawRepresentable & CaseIterable>(lhs: GraphQLEnum<T>?, rhs: T) -> Bool
where T.RawValue == String {
  return lhs?.rawValue != rhs.rawValue
}

// MARK: Pattern Matching
extension GraphQLEnum {
  /// Pattern Matching Operator overload for ``GraphQLEnum``
  ///
  /// This operator allows for a ``GraphQLEnum`` to be matched against a `case` on the wrapped
  /// ``EnumType``.
  ///
  /// > Note: Because this is not a synthesized pattern, the Swift compiler cannot determine
  /// switch case exhaustiveness. When used in a switch statement, you will be required to provide
  /// a `default` case.
  ///
  /// ```swift
  /// let enumValue: GraphQLEnum<StarWarsAPI.Episode> = .case(.NEWHOPE)
  ///
  /// switch enumValue {
  /// case .NEWHOPE:
  ///   print("Success")
  /// case .RETURN, .EMPIRE:
  ///   print("Fail")
  /// default:
  ///   print("Fail") // This default case will never be executed but is required.
  /// }
  /// ```
  @inlinable public static func ~=(lhs: T, rhs: GraphQLEnum<T>) -> Bool {
    switch rhs {
    case let .case(rhs) where rhs == lhs: return true
    case let .unknown(rhsRawValue) where rhsRawValue == lhs.rawValue: return true
    default: return false
    }
  }
}
