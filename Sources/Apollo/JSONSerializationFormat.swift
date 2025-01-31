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

  private class func deserializeJSONValue(data: Data) throws -> JSONValue {
    return try JSONSerialization.jsonObject(with: data, options: []) as! AnyHashable as JSONValue
  }

  public class func deserialize(data: Data) throws -> [JSONValue] {
    let value = try deserializeJSONValue(data: data)
    guard let array = value as? [JSONValue] else {
      throw JSONDecodingError.couldNotConvert(value: value, to: [JSONValue].self)
    }
    return array
  }

  public class func deserialize(data: Data) throws -> JSONObject {
    let value = try deserializeJSONValue(data: data)
    return try JSONObject(_jsonValue: value)
  }
}
