import Foundation

final class JSONSerializationFormat {
  func serialize(map: GraphQLMap) throws -> Data {
    return try JSONSerialization.data(withJSONObject: map.jsonValue, options: [])
  }
  
  func deserialize(data: Data) throws -> GraphQLMap {
    guard let jsonObject = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
      throw JSONDecodingError.invalidData
    }
    
    return GraphQLMap(jsonObject: jsonObject)
  }
}
