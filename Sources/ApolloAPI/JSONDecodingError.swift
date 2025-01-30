import Foundation

/// An error thrown while decoding `JSON`.
///
/// This error should be thrown when a ``JSONDecodable`` initialization fails.
/// `GraphQLExecutor` and `ApolloStore` may also throw this error when decoding a `JSON` fails.
public enum JSONDecodingError: Error, LocalizedError, Hashable {
  /// A value that is expected to be present is missing from the ``JSONObject``.
  case missingValue
  /// A value that is non-null has a `null`value.
  case nullValue
  /// A value in a ``JSONObject`` was not of the expected `JSON` type.
  /// (eg. An object instead of a list)
  case wrongType
  /// The `value` could not be converted to the expected type.
  ///
  /// This error is thrown when a ``JSONDecodable`` initialization fails for the expected type.
  case couldNotConvert(value: JSONValue, to: Any.Type)

  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }

  public static func == (lhs: JSONDecodingError, rhs: JSONDecodingError) -> Bool {
    switch (lhs, rhs) {
    case (.missingValue, .missingValue),
      (.nullValue, .nullValue),
      (.wrongType, .wrongType):
      return true

    case let (.couldNotConvert(value: lhsValue, to: lhsType),
              .couldNotConvert(value: rhsValue, to: rhsType)):
      return AnyHashable(lhsValue) == AnyHashable(rhsValue) && lhsType == rhsType

    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
}
