/// A protocol that a generated enum from a GraphQL schema conforms to.
/// This allows it to be wrapped in a `GraphQLEnum` and be used as an input value for operations.
public protocol EnumType:
  RawRepresentable,
  CaseIterable,
  JSONEncodable,
  GraphQLOperationVariableValue
where RawValue == String {}

/// A generic enum that wraps a generated enum from a GraphQL Schema.
///
/// `GraphQLEnum` provides an `__unknown` case that is used when the response returns a value that
/// is not recognized as a valid enum case. This is usually caused by future cases added to the enum
/// on the schema after code generation.
public enum GraphQLEnum<T: EnumType>: CaseIterable, Equatable, RawRepresentable {
  public typealias RawValue = String

  /// A recognized case of the wrapped enum.
  case `case`(T)

  /// An unrecognized value for the enum.
  /// The associated value exposes the raw `String` data from the response.
  case __unknown(String)

  public init(_ caseValue: T) {
    self = .case(caseValue)
  }

  public init(rawValue: String) {
    guard let caseValue = T(rawValue: rawValue) else {
      self = .__unknown(rawValue)
      return
    }
    self = .case(caseValue)
  }

  public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }

  /// The underlying enum case. If the value is `__unknown`, this will be `nil`.
  public var value: T? {
    switch self {
    case let .case(value): return value
    default: return nil
    }
  }

  public var rawValue: String {
    switch self {
    case let .case(value): return value.rawValue
    case let .__unknown(value): return value
    }
  }

  /// A collection of all known values of the wrapped enum.
  /// This collection does not include the `__unknown` case.
  public static var allCases: [GraphQLEnum<T>] {
    return T.allCases.map { .case($0) }
  }
}

// MARK: CustomScalarType
extension GraphQLEnum: CustomScalarType {
  public init(jsonValue: JSONValue) throws {
    guard let stringData = jsonValue as? String else {
      throw JSONDecodingError.couldNotConvert(value: jsonValue, to: String.self)      
    }
    self.init(rawValue: stringData)
  }

  public var jsonValue: Any { rawValue }
}

// MARK: Equatable
extension GraphQLEnum {
  public static func ==(lhs: GraphQLEnum<T>, rhs: GraphQLEnum<T>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  public static func ==(lhs: GraphQLEnum<T>, rhs: T) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  public static func !=(lhs: GraphQLEnum<T>, rhs: T) -> Bool {
    return lhs.rawValue != rhs.rawValue
  }
}

// MARK: Optional<GraphQLEnum<T>> Equatable

public func ==<T: RawRepresentable & CaseIterable>(lhs: GraphQLEnum<T>?, rhs: T) -> Bool
where T.RawValue == String {
  return lhs?.rawValue == rhs.rawValue
}

public func !=<T: RawRepresentable & CaseIterable>(lhs: GraphQLEnum<T>?, rhs: T) -> Bool
where T.RawValue == String {
  return lhs?.rawValue != rhs.rawValue
}

// MARK: Pattern Matching
extension GraphQLEnum {
  public static func ~=(lhs: T, rhs: GraphQLEnum<T>) -> Bool {
    switch rhs {
    case let .case(rhs) where rhs == lhs: return true
    case let .__unknown(rhsRawValue) where rhsRawValue == lhs.rawValue: return true
    default: return false
    }
  }
}
