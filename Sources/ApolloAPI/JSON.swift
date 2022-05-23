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

// MARK: Helpers

public struct JSONValueMatcher {

  public static func equals(_ lhs: Any, _ rhs: Any) -> Bool {
    if let lhs = lhs as? CacheReference, let rhs = rhs as? CacheReference {
      return lhs == rhs
    }

    if let lhs = lhs as? Array<CacheReference>, let rhs = rhs as? Array<CacheReference> {
      return lhs == rhs
    }

    let lhs = lhs as AnyObject, rhs = rhs as AnyObject
    return lhs.isEqual(rhs)
  }

}
