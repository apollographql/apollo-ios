import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public typealias JSONValue = Any
public typealias JSONObject = [String: JSONValue]

public final class JSONSerializationFormat {
  public class func serialize(value: JSONEncodable) throws -> Data {
    return try JSONSerialization.sortedData(withJSONObject: value.jsonValue)
  }

  public class func deserialize(data: Data) throws -> JSONValue {
    return try JSONSerialization.jsonObject(with: data, options: [])
  }
}
