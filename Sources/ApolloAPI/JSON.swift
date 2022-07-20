import Foundation

/// Represents a value in a ``JSONObject``
///
/// Making ``JSONValue`` an `AnyHashable` enables comparing ``JSONObject``s
/// in `Equatable` conformances.
public typealias JSONValue = AnyHashable

public typealias JSONObject = [String: JSONValue]
public typealias JSONEncodableDictionary = [String: JSONEncodable]

public protocol JSONDecodable: AnyHashableConvertible {
  init(jsonValue value: JSONValue) throws
}

public protocol JSONEncodable {
  var jsonValue: JSONValue { get }
}
