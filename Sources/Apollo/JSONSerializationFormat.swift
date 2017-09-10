import Foundation

public final class JSONSerializationFormat {
  public class func serialize(value: JSONEncodable) throws -> Data {
    return try JSONSerialization.data(withJSONObject: value.jsonValue, options: [])
  }
  
  public class func deserialize(data: Data) throws -> JSONValue {
    return try JSONSerialization.jsonObject(with: data, options: [])
  }
}
