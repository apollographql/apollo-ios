import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public final class JSONSerializationFormat {
  public class func serialize(value: any JSONEncodable) throws -> Data {
    return try JSONSerialization.sortedData(withJSONObject: value._jsonValue)
  }

  public class func serialize(value: JSONObject) throws -> Data {
    return try JSONSerialization.sortedData(withJSONObject: value)
  }

  public class func deserialize(data: Data) throws -> JSONValue {
    return try JSONSerialization.jsonObject(with: data, options: []) as! JSONValue
  }
}
