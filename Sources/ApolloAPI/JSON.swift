import Foundation

public typealias JSONValue = AnyHashable
public typealias JSONObject = [String: JSONValue]
public typealias JSONEncodableDictionary = [String: JSONEncodable]

public protocol JSONDecodable {
  init(jsonValue value: JSONValue) throws
}

public protocol JSONEncodable {
  var jsonValue: JSONValue { get }
}
