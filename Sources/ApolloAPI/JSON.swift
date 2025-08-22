/// Represents a value in a ``JSONObject``
///
/// - precondition: A `JSONValue` must be values types that are valid for JSON
/// serialization and must be both `Hashable` and `Sendable`. This typealias does not validate
/// that the its values are valid JSON. It functions only as an indicator of the semantic intentions
/// of the underlying value.
public typealias JSONValue = any Sendable & Hashable

/// Represents a JSON Dictionary
///
/// - precondition: A `JSONObject` must only contain values types that are valid for JSON
/// serialization and must be both `Hashable` and `Sendable`. This typealias does not validate
/// that the its values are valid JSON. It functions only as an indicator of the semantic intentions
/// of the underlying value.
public typealias JSONObject = [String: JSONValue]

/// Represents a Dictionary that can be converted into a ``JSONObject``
///
/// To convert to a ``JSONObject``:
/// ```swift
/// dictionary.mapValues { $0.jsonValue }
/// ```
public typealias JSONEncodableDictionary = [String: any JSONEncodable]

/// A protocol for a type that can be initialized from a ``JSONValue``.
///
/// This is used to interoperate between the type-safe Swift models and the `JSON` in a
/// GraphQL network response/request or the `NormalizedCache`.
public protocol JSONDecodable: Sendable {

  /// Intializes the conforming type from a ``JSONValue``.
  ///
  /// > Important: For a type that conforms to both ``JSONEncodable`` and ``JSONDecodable``,
  /// the `jsonValue` passed to this initializer should be equal to the value returned by the
  /// initialized entity's ``JSONEncodable/jsonValue`` property.
  ///
  /// - Parameter value: The ``JSONValue`` to convert to the ``JSONDecodable`` type.
  ///
  /// - Throws: A ``JSONDecodingError`` if the `jsonValue` cannot be converted to the receiver's
  /// type.
  @_spi(Internal)
  init(_jsonValue value: JSONValue) throws
}

/// A protocol for a type that can be converted into a ``JSONValue``.
///
/// This is used to interoperate between the type-safe Swift models and the `JSON` in a
/// GraphQL network response/request or the `NormalizedCache`.
public protocol JSONEncodable: Sendable {

  /// Converts the type into a ``JSONValue`` that can be sent in a GraphQL network request or
  /// stored in the `NormalizedCache`.
  ///
  /// > Important: For a type that conforms to both ``JSONEncodable`` and ``JSONDecodable``,
  /// the return value of this function, when passed to ``JSONDecodable/init(jsonValue:)`` should
  /// initialize a value equal to the receiver.
  @_spi(Internal)
  var _jsonValue: JSONValue { get }
}
