import Foundation
@_spi(Internal) @_spi(Execution) import Apollo
import ApolloAPI

private let serializedReferenceKey = "$reference"

enum SQLiteSerialization {
  static func serialize(fields: Record.Fields) throws -> Data {
    let jsonObject = try fields.compactMapValues(serialize(fieldValue:))
    return try JSONSerialization.data(withJSONObject: jsonObject, options: [])
  }

  private static func serialize(fieldValue: Record.Value) throws -> Any {
    switch fieldValue {
    case let reference as CacheReference:
      return [serializedReferenceKey: reference.key]
    case let array as [Record.Value]:
      return try array.map { try serialize(fieldValue: $0) }
    default:
      return fieldValue
    }
  }

  static func deserialize(data: Data) throws -> Record.Fields {
    let jsonObject = try JSONSerializationFormat.deserialize(data: data) as JSONObject    
    var fields = Record.Fields()
    for (key, value) in jsonObject {
      fields[key] = try deserialize(fieldJSONValue: value)
    }
    return fields
  }

  private static func deserialize(fieldJSONValue: JSONValue) throws -> Record.Value {
    switch fieldJSONValue {
    case let dictionary as JSONObject:
      guard let reference = dictionary[serializedReferenceKey] as? String else {
        return fieldJSONValue
      }
      return CacheReference(reference)
    case let array as [JSONValue]:
      return try array.map { try deserialize(fieldJSONValue: $0) } as Record.Value
    default:
      return fieldJSONValue
    }
  }
}
